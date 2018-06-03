describe Daru::View, "Update JS files" do
  context "command usage" do
    it "shows the command usage description" do
      flag = system('daru-view')
      expect(flag).to eq(true)
    end
  end

  context "googlecharts" do
    it "updates google charts javascript dependent files" do
      flag = system('daru-view update -g')
      expect(flag).to eq(true)
    end
  end

  context "highcharts" do
    it "updates high charts javascript dependent files" do
      flag = system('daru-view update -H')
      expect(flag).to eq(true)
    end
  end
end
