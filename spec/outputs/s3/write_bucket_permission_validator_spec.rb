# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/s3/write_bucket_permission_validator"
require "aws-sdk"

describe LogStash::Outputs::S3::WriteBucketPermissionValidator do
  let(:bucket_name) { "foobar" }
  let(:obj) { double("s3_object") }
  let(:client) { Aws::S3::Client.new(stub_responses: true) }
  let(:bucket) { Aws::S3::Bucket.new(bucket_name, :client => client) }

  subject { described_class }

  before do
    expect(bucket).to receive(:object).with(any_args).and_return(obj)
  end

  context "when permissions are sufficient" do
    it "returns true" do
      expect(obj).to receive(:upload_file).with(any_args).and_return(true)
      expect(obj).to receive(:delete).and_return(true)
      expect(subject.valid?(bucket)).to be_truthy
    end

    it "hides delete errors" do
      expect(obj).to receive(:upload_file).with(any_args).and_return(true)
      expect(obj).to receive(:delete).and_raise(StandardError)
      expect(subject.valid?(bucket)).to be_truthy
    end
  end

  context "when permission aren't sufficient" do
    it "returns false" do
      expect(obj).to receive(:upload_file).with(any_args).and_raise(StandardError)
      expect(subject.valid?(bucket)).to be_falsey
    end
  end
end
