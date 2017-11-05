json.total @total
json.page @page
json.limit @limit
json.data @data, partial: 'users/public_user', as: :user
