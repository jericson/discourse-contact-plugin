import { fillIn, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import pretender, {
  parsePostData,
  response,
} from "discourse/tests/helpers/create-pretender";
import formKit from "discourse/tests/helpers/form-kit-helper";
import ContactForm from "discourse/plugins/discourse-contact-plugin/discourse/components/contact-form";

module("Integration | Component | contact-form", function (hooks) {
  setupRenderingTest(hooks);

  hooks.beforeEach(function () {
    // The component fetches existing contacts as soon as it's created.
    pretender.get("/contacts", () => response({ contacts: [] }));
  });

  test("it renders a field for each piece of contact info", async function (assert) {
    await render(<template><ContactForm /></template>);

    assert.true(formKit().hasField("name"), "has a name field");
    assert.true(formKit().hasField("email"), "has an email field");
    assert.true(formKit().hasField("phone"), "has a phone field");
    assert.true(formKit().hasField("message"), "has a message field");
    assert
      .dom(".alert-success")
      .doesNotExist("no thank-you message before submitting");
  });

  test("submitting valid info saves the contact and shows a thank-you message", async function (assert) {
    pretender.put("/contacts/:contact_id", (request) => {
      const { contact } = parsePostData(request.requestBody);
      assert.step("contact saved");
      assert.strictEqual(contact.name, "Jon Ericson");
      assert.strictEqual(contact.email, "jon@example.com");
      assert.strictEqual(contact.phone, "555-0100");
      assert.strictEqual(contact.message, "Hello there!");

      return response({ contact });
    });

    await render(<template><ContactForm /></template>);

    await fillIn('[data-name="name"] input', "Jon Ericson");
    await fillIn('[data-name="email"] input', "jon@example.com");
    await fillIn('[data-name="phone"] input', "555-0100");
    await fillIn('[data-name="message"] textarea', "Hello there!");

    await formKit().submit();

    assert.verifySteps(["contact saved"]);
    assert
      .dom(".alert-success")
      .hasText("Thank you for your message.", "shows the thank-you message");
  });

  test("requires an email address before submitting", async function (assert) {
    await render(<template><ContactForm /></template>);

    await fillIn('[data-name="name"] input', "Jon Ericson");
    await formKit().submit();

    assert.form().field("email").hasError("Required");
    assert
      .dom(".alert-success")
      .doesNotExist("the form isn't submitted when validation fails");
  });
});
