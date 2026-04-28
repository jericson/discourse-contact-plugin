import Component from "@glimmer/component";
import { Input, Textarea } from "@ember/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { i18n } from "discourse-i18n";

export default class ContactForm extends Component {
  init() {
    super.init();
    this.set("contacts", []);
    /* TODO: I've disabled the /contacts route to avoid leaking user data. */
    this.fetchContacts();
    this.set("sent", "");
  }

  fetchContacts() {
    this.store.findAll("contact").then((result) => {
      for (const contact of result.content) {
        this.contacts.pushObject(contact);
      }
    });
  }

  @action
  createContact(name, email, phone, message) {
    const contactRecord = this.store.createRecord("contact", {
      id: Date.now(),
      name,
      email,
      phone,
      message,
    });

    contactRecord.save().then((result) => {
      this.contacts.pushObject(result.target);
    });

    this.set("sent", "true");
  }

  deleteContact(contact) {
    this.store.destroyRecord("contact", contact).then(() => {
      this.contacts.removeObject(contact);
    });
  }

  <template>
    <form
      {{on
        "submit"
        (fn this.createContact this.name this.email this.phone this.message)
      }}
      class="contact"
      id="contact-form"
    >
      <label>
        {{i18n "contact.create_contact.text_name_label"}}
        {{Input
          required="required"
          class="form-control"
          type="text"
          value=this.name
        }}
      </label>

      <label>
        {{i18n "contact.create_contact.text_email_label"}}
        {{Input required=true type="text" value=this.email}}
      </label>

      <label>
        {{i18n "contact.create_contact.text_phone_label"}}
        {{Input type="text" value=this.phone}}
      </label>

      <label>
        {{i18n "contact.create_contact.text_message_label"}}
        {{Textarea value=this.message}}
      </label>

      {{#if this.sent}}
        <p class="thanks">Thanks! We'll contact you soon.</p>
      {{else}}
        <button type="submit" class="btn btn-primary">
          {{i18n "contact.create_contact.submit_label"}}
        </button>
      {{/if}}
    </form>
  </template>
}
