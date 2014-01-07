json.array!(@pages) do |page|
  json.extract! page, :id, :url, :status
  json.url page_url(page, format: :json)
end
