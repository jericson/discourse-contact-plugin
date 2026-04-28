import Component from "@glimmer/component";
import { classNames } from "@ember-decorators/component";
import ContactForm from "../../components/contact-form";

@classNames("topic-above-posts-outlet", "contact")
export default class ContactConnector extends Component {
  get hasContactTag() {
    return this.args.model?.tags?.find((e) => e.name === "contact");
  }

  <template>
    {{#if this.hasContactTag}}
      <ContactForm />
    {{/if}}
  </template>
}
