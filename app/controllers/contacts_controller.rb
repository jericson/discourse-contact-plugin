# frozen_string_literal: true
class ContactsController < ApplicationController
  requires_plugin "discourse-contact-plugin"

  #  requires_login
  before_action :ensure_admin, only: %i[index destroy]

  skip_before_action :check_xhr,
                     :verify_authenticity_token,
                     :redirect_to_login_if_required,
                     only: [:create]

  def create
    Rails.logger.info "Called ContactsController#update"

    contact_id = params[:contact_id]
    contact_id = Digest::MD5.hexdigest(Time.now.to_i.to_s + params[:contact][:email])
    contact = {
      "id" => contact_id,
      "name" => params[:contact][:name],
      "email" => params[:contact][:email],
      "phone" => params[:contact][:phone],
      "message" => params[:contact][:message],
    }

    ContactStore.add_contact(contact_id, contact)

    @date = Time.now.strftime("%a, %-d %b %Y %H:%M:%S  %z'")
    @time = Time.now.in_time_zone("Eastern Time (US & Canada)").strftime("%m/%d/%Y %H:%M %p")

    @mail =
      "
Date: #{@date}
From: #{contact["email"] || "unknown@example.com"}
To: #{SiteSetting.contact_form_email}
Subject: Contact from #{contact["name"]} - #{@time}


Name:  #{contact["name"]}
Phone: #{contact["phone"]}
Email: #{contact["email"]}

Message:

#{contact["message"]}"

    Mail.new(@mail).message_id.presence

    receiver = Email::Receiver.new(@mail)
    receiver.process!

    render json: { contact: contact }
  end

  def index
    Rails.logger.info "Called ContactsController#index"
    contacts = ContactStore.get_contacts()

    render json: { contacts: contacts.values }
  end

  def destroy
    Rails.logger.info "Called ContactsController#destroy"

    ContactStore.remove_contact(params[:contact_id])

    render json: success_json
  end
end
