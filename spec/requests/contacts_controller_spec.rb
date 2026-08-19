# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContactsController do
  fab!(:user)
  fab!(:admin)

  let(:receiver) { instance_double(Email::Receiver, process!: true) }
  let(:sent_mail) { [] }
  let(:contact_params) do
    { name: "Jane Doe", email: "jane@example.com", phone: "555-1234", message: "Hello there" }
  end

  before do
    SiteSetting.contact_form_enabled = true
    allow(Email::Receiver).to receive(:new) do |mail_text|
      sent_mail << mail_text
      receiver
    end
  end

  after { PluginStore.remove("contact", "contacts") }

  describe "#create" do
    it "allows a signed-out visitor to submit the form" do
      put "/contacts/new.json", params: { contact: contact_params }

      expect(response.status).to eq(200)
      contact = response.parsed_body["contact"]
      expect(contact["name"]).to eq("Jane Doe")
      expect(contact["email"]).to eq("jane@example.com")
    end

    it "stores the submitted contact" do
      expect { put "/contacts/new.json", params: { contact: contact_params } }.to change {
        ContactStore.get_contacts.size
      }.by(1)
    end

    it "hands the constructed message to the mail receiver" do
      put "/contacts/new.json", params: { contact: contact_params }

      expect(receiver).to have_received(:process!)
    end

    it "ignores any contact_id supplied in the URL and generates its own" do
      put "/contacts/hijacked-id.json", params: { contact: contact_params }

      expect(ContactStore.get_contacts.keys).not_to include("hijacked-id")
    end

    it "does not let a newline in the name or email inject extra mail headers" do
      malicious_params =
        contact_params.merge(
          name: "Jane\r\nBcc: attacker@evil.com",
          email: "jane@example.com\r\nBcc: attacker@evil.com",
        )

      put "/contacts/new.json", params: { contact: malicious_params }

      expect(response.status).to eq(200)
      header_lines =
        sent_mail.first.split(/\r?\n\r?\n/, 2).first.lines.map(&:strip).reject(&:blank?)

      # The injected "Bcc:" text must stay folded into the From/Subject value on
      # its own line, not become a header line of its own.
      expect(header_lines.size).to eq(4)
      expect(header_lines).not_to include(a_string_matching(/\ABcc:/i))
    end
  end

  describe "#index" do
    before { ContactStore.add_contact("abc", { "id" => "abc", "name" => "Jane Doe" }) }

    it "is not accessible to a signed-out visitor" do
      get "/contacts.json"

      expect(response.status).to eq(404)
    end

    it "is not accessible to a non-admin user" do
      sign_in(user)

      get "/contacts.json"

      expect(response.status).to eq(403)
    end

    it "returns the stored contacts to an admin" do
      sign_in(admin)

      get "/contacts.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["contacts"].map { |c| c["id"] }).to contain_exactly("abc")
    end
  end

  describe "#destroy" do
    before { ContactStore.add_contact("abc", { "id" => "abc", "name" => "Jane Doe" }) }

    it "is not accessible to a signed-out visitor" do
      delete "/contacts/abc.json"

      expect(response.status).to eq(404)
      expect(ContactStore.get_contacts).to have_key("abc")
    end

    it "is not accessible to a non-admin user" do
      sign_in(user)

      delete "/contacts/abc.json"

      expect(response.status).to eq(403)
      expect(ContactStore.get_contacts).to have_key("abc")
    end

    it "allows an admin to remove a contact" do
      sign_in(admin)

      delete "/contacts/abc.json"

      expect(response.status).to eq(200)
      expect(ContactStore.get_contacts).not_to have_key("abc")
    end
  end
end
