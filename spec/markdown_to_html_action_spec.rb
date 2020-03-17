describe Fastlane::Actions::MarkdownToHtmlAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The markdown_to_html plugin is working!")

      Fastlane::Actions::MarkdownToHtmlAction.run(nil)
    end
  end
end
