ANY_NUMERIC_VALUE = 235738452
ANY_VALUE = '_ANY_VALUE_'

shared_context "pusher server client" do

  before do
    @_pusher_stub = stub_pusher  if do_stub_pusher && !@_pusher_stub
  end

  after do
    remove_request_stub @_pusher_stub  if @_pusher_stub
    @_pusher_stub = nil
  end

  def pusher_body(event, channels, data=nil)
    body = {
      name: event,
      channels: channels
    }
    body[:data] = data.to_json  if data
    body
  end

  def stub_pusher(body=nil)
    host = Pusher.host
    host += ":#{Pusher.port}"  unless !Pusher.port || Pusher.port == 80
    uri_template = Addressable::Template.new "http://#{host}/apps/{app_id}/events{?auth_key,auth_signature,auth_timestamp}{&other*}"
    stub = stub_request(:post, uri_template)
    stub = stub.
      with(
        # XXX https://github.com/bblimke/webmock/issues/432
        body: Regexp.new(Regexp.escape(body.to_json).gsub(ANY_VALUE, '.+').gsub(ANY_NUMERIC_VALUE.to_s, '\\d+')),
        headers: {
          'Accept'=>'*/*',
          'Content-Type'=>'application/json',
          'Date'=>//,
          'User-Agent'=>//
        }
      )  if body
    stub.
      to_return status: 200, body: {}.to_json, headers: {}
  end

end


shared_context "pusher server client testing", :notifications => :test do
  include_context "pusher server client" do
    let(:do_stub_pusher) { false }
  end
end

shared_context "pusher server client dummy model", :type => :model do
  include_context "pusher server client" do
    let(:do_stub_pusher) { true }
  end
end

shared_context "pusher server client dummy controller", :type => :controller do
  include_context "pusher server client" do
    let(:do_stub_pusher) { true }
  end
end
