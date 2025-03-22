require "test_helper"

module Destinations
  class GitRepositoryTest < ActiveSupport::TestCase
    test "is a valid destination subclass" do
      source = sources(:oai)
      collection = Collection.create!(source: source, name: "Test Collection for Git", identifier: "/repositories/4")
      destination = Destinations::GitRepository.new(
        name: "Git Repo", 
        url: "https://github.com/example/repo.git", 
        collection: collection
      )

      assert destination.valid?
      assert_equal "Destinations::GitRepository", destination.type
    end
  end
end