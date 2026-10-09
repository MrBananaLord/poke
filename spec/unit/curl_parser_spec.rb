require 'poke/curl_parser'

RSpec.describe Poke::CurlParser do
  def resolved(content, variables)
    described_class.new(content).to_resolved_command(variables)
  end

  it 'fills unquoted variables' do
    command = resolved('curl $BASE_URL/get -G -d foo=bar', 'BASE_URL' => 'https://example.test')

    expect(command).to eq('curl https://example.test/get -G -d foo=bar')
  end

  it 'fills ${VAR} and double-quoted variables' do
    content = 'curl "${BASE_URL}/users" -H "Authorization: Bearer $TOKEN"'
    command = resolved(content, 'BASE_URL' => 'https://example.test', 'TOKEN' => 's3cret')

    expect(command).to eq('curl "https://example.test/users" -H "Authorization: Bearer s3cret"')
  end

  it 'leaves single-quoted and escaped variables untouched' do
    content = "curl '$BASE_URL/get' -H \"\\$TOKEN\""
    command = resolved(content, 'BASE_URL' => 'https://example.test', 'TOKEN' => 's3cret')

    expect(command).to eq("curl '$BASE_URL/get' -H \"\\$TOKEN\"")
  end

  it 'leaves unknown variables in place' do
    command = resolved('curl $BASE_URL/$UNKNOWN', 'BASE_URL' => 'https://example.test')

    expect(command).to eq('curl https://example.test/$UNKNOWN')
  end

  it 'quotes values that are unsafe outside quotes' do
    command = resolved('curl $BASE_URL', 'BASE_URL' => "https://example.test/a?b=1&c=2")

    expect(command).to eq("curl 'https://example.test/a?b=1&c=2'")
  end

  it 'joins arguments with line continuations when multiline' do
    command = described_class.new('curl $BASE_URL/get -G -d foo=bar')
                             .to_resolved_command({ 'BASE_URL' => 'https://example.test' }, multiline: true)

    expect(command).to eq("curl \\\n  https://example.test/get \\\n  -G \\\n  -d foo=bar")
  end

  it 'pretty-prints a json body inside a shell-safe quoted string' do
    content = 'curl -H "Content-Type: application/json" -d \'{"from":1,"to":2,"label":"a b"}\' $BASE_URL/range'
    command = described_class.new(content).to_resolved_command(
      { 'BASE_URL' => 'https://example.test' },
      multiline: true
    )

    expect(command).to eq(<<~CMD.chomp)
      curl \\
        -H "Content-Type: application/json" \\
        -d '{
          "from": 1,
          "to": 2,
          "label": "a b"
        }' \\
        https://example.test/range
    CMD
  end

  it 'pretty-prints json passed with --data= and keeps apostrophes executable' do
    content = <<~CURL.chomp
      curl --data='{"name":"o'\\''brien","n":1}' $BASE_URL
    CURL
    command = described_class.new(content).to_resolved_command(
      { 'BASE_URL' => 'https://example.test' },
      multiline: true
    )

    expect(command).to eq(<<~CMD.chomp)
      curl \\
        --data '{
          "name": "o'\\''brien",
          "n": 1
        }' \\
        https://example.test
    CMD
  end

  it 'quotes an empty value' do
    command = resolved('curl $BASE_URL/get', 'BASE_URL' => '')

    expect(command).to eq("curl ''/get")
  end

  it 'escapes quotes inside substituted values' do
    content = 'curl "$BASE_URL" -H "X-Token: $TOKEN" -d $BODY'
    command = resolved(
      content,
      'BASE_URL' => 'https://example.test',
      'TOKEN' => 'a"b$c`d',
      'BODY' => "x'y"
    )

    expect(command).to eq("curl \"https://example.test\" -H \"X-Token: a\\\"b\\$c\\`d\" -d 'x'\\''y'")
  end
end
