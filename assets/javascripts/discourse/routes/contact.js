import DiscourseRoute from "discourse/routes/discourse";

/**
 * Route for the path `/contact` as defined in `../contact-route-map.js.es6`.
 */

export default DiscourseRoute.extend({
  renderTemplate() {
    // Renders the template `../templates/contact.hbs`
    this.render("ContactForm");
  },
});
