require 'net/http'
require 'uri'
require 'open-uri'

class WLC
  attr_accessor(:footnotes)

  def mainpath
    "https://reformed.org/documents/wlc_w_proofs/"
  end

  def urls
    {
      summary: "WLC_Intro.html",
      Q1_50:   "WLC_001-050.html",
      proofs: "WLC_fn_001-050.html"
    }.transform_values do |url|
      mainpath + url
    end
  end

  def questions
    @footnotes = get_footnotes

    results = Array.new
    open(URI(urls[:Q1_50])) do |rs|
      question = nil
      rs.each_line do |line|
        if /^<p><strong>Q\. (?'num'\d+)\. (?'text'\w.*)<\/strong><\/p>$/.match(line)
          puts "found question"
          # line contains question
          question = Question.new
          question.number = $~[:num].to_i
          question.text = $~[:text]
        elsif /^<p>A\. (?'ans'.*)<\/p>$/.match(line) && !question.nil?
          puts "found answer"
          # next line after question, should be answer
          answer = Answer.new
          answer.phrases = phrases($~[:ans])
          question.answer = answer
          results.push question
          question = nil
        else
          puts "no question or answer"
          # does not contain question or answer. reset question
          question = nil
        end
      end
    end

    return results
  end

  def get_footnotes
    # Net::HTTP.get(URI(urls[:proofs]))
    results = Hash.new
    open(URI(urls[:proofs])) do |rs|
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
    return results
  end

  def phrases(answer)
    elements = answer.split(/<a|<\/a>/)
    return nil if elements.nil? || elements.length < 2 || elements.length.odd?
    results = Array.new
    elements.each_slice(2) do |sl|
      phrase = Phrase.new
      phrase.text = sl[0]
      # phrase.verse = sl[1].match(/(?<=href\=\").*(?=\" target)/)[0]
      unless sl[1].match(/(?<=href\=\").*#fn(?'id'\d+)(?=\" target)/).nil?
        phrase.verse = @footnotes[$~[:id]]
      end
      results.push phrase
    end

    return results
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
