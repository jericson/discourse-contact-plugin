/**
 * Links the path `/contact` to a route named `contact`. Named like this, a
 * route with the same name needs to be created in the `routes` directory.
 */
export default {
  path: "contact",
  map() {
    this.route("contact");
  },
};
