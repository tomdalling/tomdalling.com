module Statue
  class SocialMetadata
    value_semantics do
      title String
      image_url Either(FullURL, nil)
    end
  end
end
