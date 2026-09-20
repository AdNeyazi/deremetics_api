# Crash on boot (not on first login) if a required secret is missing or weak.
# Must run after_initialize because app/services is not autoloadable yet
# while initializers are running.
Rails.application.config.after_initialize do
  JwtToken.secret if Rails.env.production?
end
