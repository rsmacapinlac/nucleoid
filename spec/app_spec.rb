require File.expand_path '../spec_helper.rb', __FILE__

describe "Nucleoid" do
  context "twilio receivers" do
    let(:forwarding_number) { Faker::PhoneNumber.cell_phone }
    before(:each) do
      app.settings.app_config.set("FORWARDING_NUMBER", forwarding_number)
    end
    context "with dnd on" do
      before(:each) do
        app.settings.app_config.set("dnd", true)
      end

    end
    context "with dnd off" do
      before(:each) do
        app.settings.app_config.set("dnd", "false")
      end

      context "and without a forwarding number" do
        before(:each) do
          app.settings.app_config.set("FORWARDING_NUMBER", '')
        end
      end
    end
  end
end
