require 'net/http'
require 'uri'
require 'open-uri'

class WLC_URL
  attr_accessor(:main_location, :proof_location)
end

class WLC
  attr_accessor(:footnotes)

  def mainpath
    'https://reformed.org/documents/wlc_w_proofs/'
  end

  def urls
    [
      '001-050',
      '051-090',
      '091-150',
      '151-196',
    ].map do |segment|
      url = WLC_URL.new
      # set main location
      path = 'WLC_' + segment + '.html'
      l = mainpath + path
      url.main_location = URI(l)

      # set proof location
      path = 'WLC_fn_' + segment + '.html'
      l = mainpath + path
      url.proof_location = URI(l)

      url
    end
  end

  def questions
    @footnotes = get_footnotes

    results = []
    urls.each do |url|
      open(url.main_location) do |rs|
        question = nil
        rs.each_line do |line|
          if /^<p><strong>Q\. (?'num'\d+)\. (?'text'\w.*)<\/strong><\/p>$/.match(line)
            # line contains question
            question = Question.new
            question.number = $~[:num].to_i
            question.text = $~[:text]
          elsif /^<p>A\. (?'ans'.*)<\/p>$/.match(line) && !question.nil?
            # next line after question, should be answer
            answer = Answer.new
            answer.phrases = phrases($~[:ans])
            question.answer = answer
            results.push question
            question = nil
          else
            # does not contain question or answer. reset question
            question = nil
          end
        end
      end
    end

    return results
  end

  def get_footnotes
    results = {}
    urls.each do |url|
      puts 'opening uri ' + url.proof_location.to_s
      open(url.proof_location) do |rs|
        rs.each_line do |line|
          # check that current line contains footnote
          unless /href="WLC_001-050\.html#fnB(?'id'\d+)/.match(line).nil?
            verses = Array.new
            # footnote id used as keys in result
            id = $~[:id]
            # multiple verses may be present. split and act on this
            line.split(/<strong>/).each do |l|
              unless /(?'verse'^[\w|\s|\d|:|-]+)\.<\/strong>(?'text'.*)/.match(l).nil?
                verse = Verse.new
                verse.passage = $~[:verse]
                verse.text = $~[:text]
                verses.push verse
              end
            end
            # footnote value is hash of passage name, and passage text
            results[id] = verses
          end
        end
      end
    end
    return results
  end

  def phrases(answer)
    elements = answer.split(/<a|<\/a>/)
    return nil if elements.nil? || elements.length < 2 || elements.length.odd?

    results = []
    elements.each_slice(2) do |sl|
      phrase = Phrase.new
      phrase.text = sl[0]
      unless sl[1].match(/(?<=href\=\").*#fn(?'id'\d+)(?=\" target)/).nil?
        phrase.verse = @footnotes[$~[:id]]
      end
      results.push phrase
    end

    results
  end
end

class Verse
  attr_accessor(:passage, :text)
end

class Question
  attr_accessor(:number, :text, :answer)
end

class Answer
  attr_accessor(:phrases)

  def to_s
    return nil if phrases.nil?

    phrases.map{|phrase| phrase.text}.join
  end
end

class Phrase
  attr_accessor(:text, :verse)
end

@w = WLC.new
@q = @w.questions
puts @q.select{|q| q.number == 196}.first
