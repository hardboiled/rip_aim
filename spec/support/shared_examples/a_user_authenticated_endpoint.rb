shared_examples 'a user authenticated endpoint' do
  it 'should return 401 when session[:current_user_id] not present' do
    execute_request.call
    expect(response.status).to eq(401)
  end

  it 'should return 401 when session[:current_user_id] not found' do
    session[:current_user_id] = SecureRandom.uuid
    execute_request.call
    expect(response.status).to eq(401)
  end

  it 'should return 20X when session is valid' do
    session[:current_user_id] = user.id
    execute_request.call
    expect(response.status).to be <= 204
  end
end
