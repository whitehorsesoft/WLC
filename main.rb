require 'net/http'
require 'uri'
require 'open-uri'

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

def footnotes
  # Net::HTTP.get(URI(urls[:proofs]))
  results = Hash.new
  open(URI(urls[:proofs])) do |rs|
    rs.each_line do |line|
      unless /<a name=\"fn(?'num'\d+).*<\/a> <strong>(?'verse'.*)\.<\/strong>/.match(line).nil?
        puts sprintf("num: %i, verse: %s", $~[:num], $~[:verse])
      end
    end
  end
end

def phrases(answer)
  elements = answer.split(/<a|<\/a>/)
  return nil if elements.nil? || elements.length < 2 || elements.length.odd?
  results = Array.new
  elements.each_slice(2) do |sl|
    phrase = Phrase.new
    phrase.text = sl[0]
    # phrase.verse = verse sl[1].match(/(?<=href\=\").*(?=\" target)/)[0]
    phrase.verse = sl[1].match(/(?<=href\=\").*(?=\" target)/)[0]
    results.push phrase
  end

  return results
end

def verse(path)
  open(URI(mainpath + path)) do |rs|
    return rs
  end
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