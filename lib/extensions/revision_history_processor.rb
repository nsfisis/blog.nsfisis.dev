module Nuldoc
  module Extensions
    class RevisionHistoryProcessor < Asciidoctor::Extensions::TreeProcessor
      def process(doc)
        revisions = []
        i = 1
        loop do
          break unless (rev = doc.attributes["revision-#{i}"])
          revisions << parse_revision(rev)
          i += 1
        end
        doc.attributes['revision-history'] = revisions
      end

      private

      def parse_revision(rev)
        m = rev.match(/\A(\d\d\d\d-\d\d-\d\d) (.*)\z/)
        raise unless m
        Revision.new(
          date: Date.parse(m[1], '%Y-%m-%d'),
          remark: m[2],
        )
      end
    end
  end
end
