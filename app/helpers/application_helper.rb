module ApplicationHelper
  def truncate_at_sentence(text, max_length)
    return "" if text.blank?
    return text if text.length <= max_length

    truncated = text[0..max_length]
    last_period = truncated.rindex(".")
    last_period ? text[0..last_period] : truncated
  end
end
