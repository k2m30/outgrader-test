json.array!(@testruns) do |testrun|
  json.extract! testrun, :id, :status, :passed, :failed, :total
  json.url testrun_url(testrun, format: :json)
end
