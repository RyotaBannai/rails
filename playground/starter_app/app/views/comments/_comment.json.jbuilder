json.extract! comment, :id, :commenter, :body, :created_at, :updated_at
json.url comment_url(comment, format: :json)
