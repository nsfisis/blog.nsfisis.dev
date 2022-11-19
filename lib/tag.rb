module Nuldoc
  Tag = Struct.new(:slug, :label, keyword_init: true) do
    LABELS = {
      'conference'   => 'カンファレンス',
      'cpp'          => 'C++',
      'cpp17'        => 'C++ 17',
      'note-to-self' => '備忘録',
      'php'          => 'PHP',
      'phpcon'       => 'PHP カンファレンス',
      'phperkaigi'   => 'PHPerKaigi',
      'python'       => 'Python',
      'python3'      => 'Python 3',
      'ruby'         => 'Ruby',
      'ruby3'        => 'Ruby 3',
      'rust'         => 'Rust',
      'vim'          => 'Vim',
    }

    def self.from_slug(slug)
      Tag.new(
        slug: slug,
        label: (LABELS[slug] || raise("No label for tag '#{slug}'")),
      )
    end
  end
end
