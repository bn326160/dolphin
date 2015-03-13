class User < ActiveRecord::Base
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  def self.find_for_google_oauth2(access_token)
    id_args = {provider: access_token.provider, uid: access_token.uid}
    info_args = {name: access_token.info.name, email: access_token.info.email,
                 image_url: access_token.info.image}

    if user = User.where(**id_args).first
      user.update_attributes(**info_args)
    else
      user = User.create(**info_args.merge!(id_args))
    end

    user
  end
end