json.array!(@posts) do |post|
  json.extract! post, :title, :description
  json.url post_url(post, format: :json)
end
