# frozen_string_literal: true

require "test_helper"

class RubyLlmInitializerTest < ActiveSupport::TestCase
  # The 2.2 line is unreleased: RubyGems tops out at 2.1.1 and the gem's own
  # version.rb still reads 2.1.1 on main, so only the git revision identifies
  # this pin. Bumping the ref is a deliberate act that updates this constant.
  RUBY_LLM_REF = "1feba97feb8ab28655a0128c2885721c05294b84"

  test "Gemfile.lock resolves ruby_llm from the reviewed git revision" do
    lock = Rails.root.join("Gemfile.lock").read
    stanza = lock.scan(/^GIT\n((?:  .*\n)+)/).flatten.find { |s| s.include?("crmne/ruby_llm.git") }

    assert stanza, "ruby_llm is not resolved from a git source in Gemfile.lock"
    assert_match(/^  revision: #{RUBY_LLM_REF}$/, stanza)
  end

  test "the app boots with the ruby_llm initializer loaded and no API keys set" do
    # If the initializer raised on a missing key/credential, boot would have
    # failed and this suite would not run. Assert it configured successfully.
    assert RubyLLM.config.default_model.present?
  end

  test "RUBY_LLM_MODEL unset resolves default_model to the gemini fallback" do
    assert_nil ENV["RUBY_LLM_MODEL"]
    assert_equal "gemini-2.5-flash", RubyLLM.config.default_model
  end

  test "request_timeout falls back to 60 seconds" do
    assert_equal 60, RubyLLM.config.request_timeout
  end

  test "the chat.ruby_llm subscriber logs each token bucket the gem reports" do
    io = StringIO.new
    original = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(io)

    tokens = RubyLLM::Tokens.new(input: 14, output: 5, cache_read: 2)
    ActiveSupport::Notifications.instrument("chat.ruby_llm", model: "test-model", tokens: tokens) { :ok }

    assert_match(/\[ruby_llm\] chat model=test-model/, io.string)
    assert_match(/input_tokens=14/, io.string)
    assert_match(/output_tokens=5/, io.string)
    assert_match(/cache_read_tokens=2/, io.string)
  ensure
    Rails.logger = original
  end

  test "the chat.ruby_llm subscriber logs without raising when no usage is reported" do
    io = StringIO.new
    original = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(io)

    assert_nothing_raised do
      ActiveSupport::Notifications.instrument("chat.ruby_llm", model: "test-model") { :ok }
    end

    assert_match(/\[ruby_llm\] chat model=test-model/, io.string)
    assert_match(/tokens=unknown/, io.string)
  ensure
    Rails.logger = original
  end
end
