# frozen_string_literal: true

require 'spec_helper'

describe Darlingtonia::RecordImporter do
  subject(:importer) { described_class.new(error_stream: error_stream) }
  let(:error_stream) { [] }
  let(:record)       { Darlingtonia::InputRecord.new }

  it 'raises an error when no work type exists' do
    expect { importer.import(record: record) }
      .to raise_error 'No curation_concern found for import'
  end

  context 'with a registered work type' do
    include_context 'with a work type'

    it 'creates a work for record' do
      expect(importer.import(record: record))
        .to change { Work.count }
        .by 1
    end

    context 'when input record errors unexpectedly' do
      let(:custom_error) { Class.new(RuntimeError) }

      before { allow(record).to receive(:attributes).and_raise(custom_error) }

      it 'writes errors to the error stream' do
        expect { begin; importer.import(record: record); rescue; end }
          .to change { error_stream }
          .to contain_exactly(an_instance_of(custom_error))
      end

      it 'reraises error' do
        expect { importer.import(record: record) }.to raise_error(custom_error)
      end
    end
  end
end
