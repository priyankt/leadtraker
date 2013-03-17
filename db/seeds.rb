
# Create email types
emailTypes = ['Work', 'Home', 'Other']
emailTypes.each do |type|
  newType = EmailType.create(:name => type)
  if newType.valid?
    shell.say "Created email type #{type}"
  else
    shell.say "Failed to create email type #{type}"
  end
end

# Create phone types
phoneTypes = ['Work', 'Home', 'Mobile', 'Fax', 'Other']
phoneTypes.each do |type|
  newType = PhoneType.create(:name => type)
  if newType.valid?
    shell.say "Created phone type #{type}"
  else
    shell.say "Failed to create phone type #{type}"
  end
end
