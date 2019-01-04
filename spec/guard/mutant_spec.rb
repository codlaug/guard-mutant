require "guard/compat/test/helper"
require "spec_helper"
require "guard/mutant"

RSpec.describe Guard::Mutant do

  before do
    allow(Guard::Compat::UI).to receive(:info)
  end

  it "has a version number" do
    expect(Guard::MutantVersion::VERSION).not_to be nil
  end

  describe ".initialize" do
    it "instanciates with default and custom options" do
      guard_rspec = Guard::Mutant.new(foo: :bar)
      expect(guard_rspec.options).to eq(foo: :bar)
    end
  end

end

# probably use guard-rubocop's specs as a template
# https://github.com/yujinakayama/guard-rubocop/tree/master/spec/guard
