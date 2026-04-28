# **Discourse Contact Form** Plugin

| | | |
| - | - | - |
| :information_source: | **Summary** | Adds a contact form to the top of any topic tagged `contact`. Information submitted through the form will be sent to the group or category configured to receive it. |
| :hammer_and_wrench: | **Repository Link** | <https://github.com/jericson/discourse-contact-plugin> |
| :open_book: | **Install Guide** | [How to install plugins in Discourse](https://meta.discourse.org/t/install-plugins-in-discourse/19157) |

<br>  

### Features
 
When enabled, the Contact Form plugin places a contact form at the top of any topic tagged `contact`. Data submitted via the form is sent to a category or group configured to receive mail from `contact_form_email`.^[That setting defaults to "contact@example.com" but can be configured to accept real emails.] Like traditional contact forms, there is no requirement to have an account on the site in order to submit.

### Configuration
 
In order to use this plugin, you must [configure incoming email to create new topics or group messages](https://meta.discourse.org/t/configure-incoming-email-to-create-new-topics-or-group-messages/62977). It isn't required to [set up reply by email](https://meta.discourse.org/t/troubleshoot-reply-by-email/42026) since the plugin doesn't actually send email. It hijacks the API to simulate incoming mail. (That said, reply by email is a useful feature!)

In particular, this plugin requires:

* `email_in` and
* `enable_staged_users`

to be enabled. 

Once enabled, any topic tagged `contact` will have a contact form added to the `topic-above-posts` plugin outlet.

#### Send to a group

Since people will use this form to submit their personal information, sending the results to a closed group is the safest option.

1. Create a new group for the people who will be handling contacts. (I usually call it "Contact" for simplicity, but it could be anything including an existing group.)
2. Add members who will be receiving contact information.
3. **Do not** check any of the access options. This should be a closed group.
4. Change the visibility of the group as reasonable for your organization.
5. Set the "Custom incoming email address" to be the same as the `contact_form_email` setting. (By default, this is "[contact@example.com](mailto:contact@example.com)".)

#### Send to a category

Sending to a category is also possible using the "Custom incoming email address" category setting. Be sure to enable "Accept emails from anonymous users with no accounts" as well.

**Sending to a category is not recommended for contact information, however!** If by some chance the access permissions on the category are changed, it could expose personal information to people (or search engines) that shouldn't have access. It's much less likely to happen if contacts are sent to group messages instead.

#### Limiting who can add contact forms

It could be quite odd to have contact forms sprouting up hither and yon, so you might want to limit who can use the `contact` tag. In order to do that, create a new tag group:

1. From the `/tags` page, select the wrench in the top right corner.
2. Select "Manage Tag Groups" and then select " :heavy_plus_sign: New Group".
3. Fill in an appropriate name (e.g., "Staff only"), add the `contact` tag and select "Tags are visible to everyone, but only the following groups can use them".
4. Pick the group you want to allow to add a contact form (usually "staff" or "admins") and save the tag group.

### CHANGELOG
* April 25, 2024: Alpha release.
* April 28, 2026: Updated to .gjs file format.
 
### TODO
* I'd like to set up tests to make sure nothing breaks when I make changes. I particularly want to verify that people without accounts can submit their data.
* While testing I discovered a major data leak. I removed that particular vulnerability, but I could really use some help testing.
* The form doesn't do any validation. The only real requirement is that the email field look like an email. If someone leaves a response without adding an email, the form quietly fails.
* There is no protection against spam or abuse.
* Code is very much `my-first-plugin` quality based on examples that used  outdated conventions. Any suggestions about style are welcome.
* I like having the contact form associated with a topic tagged "contact", but it's convoluted and probably unnecessary. I'm considering adding a new route that's just the contact form for simplicity.
* The contact data is stored in the database, but it might be helpful to have an admin panel to see a list of contacts. 
* The form is fixed to my current requirements, but it would be handy to have some flexibility about what fields it prompts for.

For more information, please see: [this post on Meta Discourse](https://meta.discourse.org/t/contact-form/305462).


Resources that helped me:

* [How to create a Discourse plugin](https://kleinfreund.de/how-to-create-a-discourse-plugin/)
* [Get server-side controller method to be called via plugin route](https://meta.discourse.org/t/get-server-side-controller-method-to-be-called-via-plugin-route/92186/2?u=jericson)
