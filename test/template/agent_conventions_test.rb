require "test_helper"

class AgentConventionsTest < ActiveSupport::TestCase
  ROOT = Rails.root

  test "CLAUDE.md is a symlink resolving to AGENTS.md" do
    claude = ROOT.join("CLAUDE.md")
    assert File.symlink?(claude), "CLAUDE.md must be a symlink to AGENTS.md, not a copy"
    assert_equal "AGENTS.md", File.readlink(claude)
    assert_equal File.read(ROOT.join("AGENTS.md")), File.read(claude)
  end

  test "AGENTS.md carries the standardized sections" do
    agents = File.read(ROOT.join("AGENTS.md"))
    assert_match(/never commit or push to `main`/i, agents)
    assert_match(/^## Local development/, agents)
    assert_match(/^## Deploying/, agents)
  end
end
