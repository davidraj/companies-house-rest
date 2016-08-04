# frozen_string_literal: true
require 'webmock/rspec'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'companies_house/client'
require 'timecop'

shared_context 'test credentials' do
  let(:api_key) { 'el-psy-congroo' }
  let(:example_endpoint) { URI('https://api.example.com:8000') }
  let(:company_id) { '07495895' }
end

shared_context 'test client' do
  include_context 'test credentials'

  let(:client) { described_class.new(api_key: api_key, endpoint: example_endpoint) }
  let(:status) { 200 }
end

shared_examples 'an error response' do
  it 'should raise a specific APIError' do
    expect { request }.to raise_error do |error|
      expect(error).to be_a(error_class)
      expect(error.status).to eq(status.to_s)
      expect(error.response).to be_a(Net::HTTPResponse)
      expect(error.message).to eq(message)
    end
  end
end

shared_examples 'an API that handles all errors' do
  context '404' do
    let(:status) { 404 }
    let(:message) { "Company #{company_id} not found - HTTP 404" }
    let(:error_class) { CompaniesHouse::NotFoundError }
    it_should_behave_like 'an error response'
  end

  context '429' do
    let(:status) { 429 }
    let(:message) { "Rate limit exceeded - HTTP 429" }
    let(:error_class) { CompaniesHouse::RateLimitError }
    it_should_behave_like 'an error response'
  end

  context '401' do
    let(:status) { 401 }
    let(:message) { "Invalid API key - HTTP 401" }
    let(:error_class) { CompaniesHouse::AuthenticationError }
    it_should_behave_like 'an error response'
  end

  context 'any other code' do
    let(:status) { 342 }
    let(:message) { "Unknown API response - HTTP 342" }
    let(:error_class) { CompaniesHouse::APIError }
    it_should_behave_like 'an error response'
  end
end
