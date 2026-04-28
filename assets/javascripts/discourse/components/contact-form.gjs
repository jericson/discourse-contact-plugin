import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import Form from "discourse/components/form";
import { i18n } from "discourse-i18n";

export default class ContactForm extends Component {
  @service store;

  @tracked submitted = false;

  constructor(owner, args) {
    super(owner, args);

    this.init();
  }

  init() {
    this.contacts = [];
    /* TODO: I've disabled the /contacts route to avoid leaking user data. */
    this.fetchContacts();
    //    this.set("sent", "");
  }

  fetchContacts() {
    this.store.findAll("contact").then((result) => {
      for (const contact of result.content) {
        this.contacts.push(contact);
      }
    });
  }

  @action
  handleSubmit(data) {
    // data = { name, email, phone, message }
    //      console.log(data.name);
    //      console.log(this.contacts);
    this.createContact(data.name, data.email, data.phone, data.message);
    this.submitted = true;
  }

  createContact(name, email, phone, message) {
    const contactRecord = this.store.createRecord("contact", {
      id: Date.now(),
      name,
      email,
      phone,
      message,
    });

    //  console.log("createContact");

    contactRecord.save().then((result) => {
      this.contacts.push(result.target);
    });

    //    this.set("sent", "true");
  }

  deleteContact(contact) {
    this.store.destroyRecord("contact", contact).then(() => {
      this.contacts.removeObject(contact);
    });
  }

  <template>
    {{#if this.submitted}}
      <Form as |form|>
        <form.Alert @type="success" @icon="check-circle">
          Thank you for your message.
        </form.Alert>
      </Form>
    {{else}}
      <Form @onSubmit={{this.handleSubmit}} as |form|>
        <form.Field
          @name="name"
          @title={{i18n "contact.create_contact.text_name_label"}}
          @type="input-text"
          as |field|
        >
          <field.Control />
        </form.Field>

        <form.Field
          @name="email"
          @title={{i18n "contact.create_contact.text_email_label"}}
          @type="input-email"
          @validation="required"
          as |field|
        >
          <field.Control />
        </form.Field>

        <form.Field
          @name="phone"
          @title={{i18n "contact.create_contact.text_phone_label"}}
          @type="input-tel"
          as |field|
        >
          <field.Control />
        </form.Field>

        <form.Field
          @name="message"
          @title={{i18n "contact.create_contact.text_message_label"}}
          @type="textarea"
          as |field|
        >
          <field.Control @height={{120}} />
        </form.Field>

        <form.Submit @translatedLabel="Send" />
      </Form>
    {{/if}}
  </template>
}
