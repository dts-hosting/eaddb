require "test_helper"

class RecordsControllerToolsTest < ActionDispatch::IntegrationTest
  include FactoryHelpers

  setup do
    sign_in(users(:admin))
    @record = create_record
  end

  test "should resend record" do
    assert_changes -> { @record.reload.updated_at } do
      post resend_record_url(@record)
    end
    assert_redirected_to record_url(@record)
  end

  test "should not resend failed record" do
    @record.update!(status: "failed")

    assert_no_changes -> { @record.reload.updated_at } do
      post resend_record_url(@record)
    end
    assert_redirected_to record_url(@record)
    assert_equal "Cannot transfer failed record.", flash[:alert]
  end

  test "should withdraw record" do
    assert_changes -> { @record.reload.updated_at } do
      post withdraw_record_url(@record)
    end
    assert_redirected_to record_url(@record)
  end

  test "should not withdraw failed record" do
    @record.update!(status: "failed")

    assert_no_changes -> { @record.reload.updated_at } do
      post withdraw_record_url(@record)
    end
    assert_redirected_to record_url(@record)
    assert_equal "Cannot withdraw failed record.", flash[:alert]
  end
end
