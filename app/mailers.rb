##
# Mailer methods can be defined using the simple format:
#
# email :registration_email do |name, user|
#   from 'admin@site.com'
#   to   user.email
#   subject 'Welcome to the site!'
#   locals  :name => name
#   content_type 'text/html'       # optional, defaults to plain/text
#   via     :sendmail              # optional, to smtp if defined, otherwise sendmail
#   render  'registration_email'
# end

#
# You can set the default delivery settings from your app through:
#
#
# or sendmail (default):
#
#   set :delivery_method, :sendmail
#
# or for tests:
#
#   set :delivery_method, :test
#
# and then all delivered mail will use these settings unless otherwise specified.
#

Leadtraker.mailer :notifier do
  email :invitation_email do |from_email, to_email|
    from from_email
    to   to_email
    subject 'Invitation to join LeadTraker'
    locals  :from_email => from_email
    content_type 'text/html'       # optional, defaults to plain/text
    via     :smtp              # optional, to smtp if defined, otherwise sendmail
    render  'invitation/invitation_email'
  end

  email :invitation_accepted_email do |from_user, to_user|
    from from_user.email
    to   to_user.email
    subject 'Invitation accepted'
    locals  :from_user => from_user, :to_user => to_user
    content_type 'text/html'       # optional, defaults to plain/text
    via     :smtp              # optional, to smtp if defined, otherwise sendmail
    render  'invitation/invitation_accepted_email'
  end

  email :invitation_rejected_email do |user, from_user|
    from user.email
    to   from_user.email
    subject 'Invitation rejected'
    locals  :user => user, :from_user => from_user
    content_type 'text/html'       # optional, defaults to plain/text
    via     :smtp              # optional, to smtp if defined, otherwise sendmail
    render  'invitation/invitation_rejected_email'
  end
end
