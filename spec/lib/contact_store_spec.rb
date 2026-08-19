# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContactStore do
  after { PluginStore.remove("contact", "contacts") }

  describe ".get_contacts" do
    it "returns an empty hash when nothing has been stored" do
      expect(described_class.get_contacts).to eq({})
    end
  end

  describe ".add_contact" do
    it "persists the contact and returns it" do
      contact = { "id" => "abc", "name" => "Jane Doe", "email" => "jane@example.com" }

      result = described_class.add_contact("abc", contact)

      expect(result).to eq(contact)
      expect(described_class.get_contacts).to eq({ "abc" => contact })
    end

    it "does not clobber previously stored contacts" do
      described_class.add_contact("abc", { "id" => "abc" })
      described_class.add_contact("def", { "id" => "def" })

      expect(described_class.get_contacts.keys).to contain_exactly("abc", "def")
    end

    it "overwrites a contact stored under the same id" do
      described_class.add_contact("abc", { "id" => "abc", "name" => "Jane" })
      described_class.add_contact("abc", { "id" => "abc", "name" => "Janet" })

      expect(described_class.get_contacts["abc"]["name"]).to eq("Janet")
    end
  end

  describe ".remove_contact" do
    it "deletes the given contact" do
      described_class.add_contact("abc", { "id" => "abc" })

      described_class.remove_contact("abc")

      expect(described_class.get_contacts).to eq({})
    end

    it "leaves other contacts untouched" do
      described_class.add_contact("abc", { "id" => "abc" })
      described_class.add_contact("def", { "id" => "def" })

      described_class.remove_contact("abc")

      expect(described_class.get_contacts.keys).to contain_exactly("def")
    end

    it "is a no-op when the contact does not exist" do
      expect { described_class.remove_contact("missing") }.not_to raise_error
    end
  end
end
