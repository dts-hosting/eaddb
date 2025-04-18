require "test_helper"

module Destinations
  class GitRepositoryTest < ActiveSupport::TestCase
    test "is a valid destination subclass" do
      collection = create_collection
      destination = create_destination(
        type: :git_repository,
        attributes: {collection: collection}
      )

      assert destination.valid?
      assert_equal "Destinations::GitRepository", destination.type
      assert_equal "x-access-token", destination.username
    end
  end
end
