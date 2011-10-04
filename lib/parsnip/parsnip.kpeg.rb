require 'kpeg/compiled_parser'

class Parsnip::FormatParser < KPeg::CompiledParser


  include Parsnip::Ast
  attr_reader :grammar



  # eol = "\n"
  def _eol
    _tmp = match_string("\n")
    set_failed_rule :_eol unless _tmp
    return _tmp
  end

  # space = (" " | "\t" | eol)
  def _space

    _save = self.pos
    while true # choice
      _tmp = match_string(" ")
      break if _tmp
      self.pos = _save
      _tmp = match_string("\t")
      break if _tmp
      self.pos = _save
      _tmp = apply(:_eol)
      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_space unless _tmp
    return _tmp
  end

  # - = space*
  def __hyphen_
    while true
      _tmp = apply(:_space)
      break unless _tmp
    end
    _tmp = true
    set_failed_rule :__hyphen_ unless _tmp
    return _tmp
  end

  # root = - "grammar" - rules:rules - "end" - { @grammar = Ast::Grammar.new(Array(rules)) }
  def _root

    _save = self.pos
    while true # sequence
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("grammar")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_rules)
      rules = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("end")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  @grammar = Ast::Grammar.new(Array(rules)) ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_root unless _tmp
    return _tmp
  end

  # rules = rule:first (- rule)*:rest { [first, *rest] }
  def _rules

    _save = self.pos
    while true # sequence
      _tmp = apply(:_rule)
      first = @result
      unless _tmp
        self.pos = _save
        break
      end
      _ary = []
      while true

        _save2 = self.pos
        while true # sequence
          _tmp = apply(:__hyphen_)
          unless _tmp
            self.pos = _save2
            break
          end
          _tmp = apply(:_rule)
          unless _tmp
            self.pos = _save2
          end
          break
        end # end sequence

        _ary << @result if _tmp
        break unless _tmp
      end
      _tmp = true
      @result = _ary
      rest = @result
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  [first, *rest] ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_rules unless _tmp
    return _tmp
  end

  # rule = name:name - "=" - expression:expression { Rule.new(name, expression) }
  def _rule

    _save = self.pos
    while true # sequence
      _tmp = apply(:_name)
      name = @result
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("=")
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:__hyphen_)
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = apply(:_expression)
      expression = @result
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  Rule.new(name, expression) ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_rule unless _tmp
    return _tmp
  end

  # name = !"end" < /\w+/ > { text.to_sym }
  def _name

    _save = self.pos
    while true # sequence
      _save1 = self.pos
      _tmp = match_string("end")
      _tmp = _tmp ? nil : true
      self.pos = _save1
      unless _tmp
        self.pos = _save
        break
      end
      _text_start = self.pos
      _tmp = scan(/\A(?-mix:\w+)/)
      if _tmp
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  text.to_sym ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_name unless _tmp
    return _tmp
  end

  # expression = sequence
  def _expression
    _tmp = apply(:_sequence)
    set_failed_rule :_expression unless _tmp
    return _tmp
  end

  # sequence = value:first (- value)*:rest { Sequence.new([first, *rest]) }
  def _sequence

    _save = self.pos
    while true # sequence
      _tmp = apply(:_value)
      first = @result
      unless _tmp
        self.pos = _save
        break
      end
      _ary = []
      while true

        _save2 = self.pos
        while true # sequence
          _tmp = apply(:__hyphen_)
          unless _tmp
            self.pos = _save2
            break
          end
          _tmp = apply(:_value)
          unless _tmp
            self.pos = _save2
          end
          break
        end # end sequence

        _ary << @result if _tmp
        break unless _tmp
      end
      _tmp = true
      @result = _ary
      rest = @result
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  Sequence.new([first, *rest]) ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_sequence unless _tmp
    return _tmp
  end

  # value = (rule_reference | string)
  def _value

    _save = self.pos
    while true # choice
      _tmp = apply(:_rule_reference)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_string)
      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_value unless _tmp
    return _tmp
  end

  # rule_reference = name:name !(- "=") { RuleReference.new(name) }
  def _rule_reference

    _save = self.pos
    while true # sequence
      _tmp = apply(:_name)
      name = @result
      unless _tmp
        self.pos = _save
        break
      end
      _save1 = self.pos

      _save2 = self.pos
      while true # sequence
        _tmp = apply(:__hyphen_)
        unless _tmp
          self.pos = _save2
          break
        end
        _tmp = match_string("=")
        unless _tmp
          self.pos = _save2
        end
        break
      end # end sequence

      _tmp = _tmp ? nil : true
      self.pos = _save1
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  RuleReference.new(name) ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_rule_reference unless _tmp
    return _tmp
  end

  # string = (single_quoted_string | double_quoted_string)
  def _string

    _save = self.pos
    while true # choice
      _tmp = apply(:_single_quoted_string)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_double_quoted_string)
      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_string unless _tmp
    return _tmp
  end

  # single_quoted_string = "'" < /[^']*/ > "'" { StringLiteral.new(text) }
  def _single_quoted_string

    _save = self.pos
    while true # sequence
      _tmp = match_string("'")
      unless _tmp
        self.pos = _save
        break
      end
      _text_start = self.pos
      _tmp = scan(/\A(?-mix:[^']*)/)
      if _tmp
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("'")
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  StringLiteral.new(text) ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_single_quoted_string unless _tmp
    return _tmp
  end

  # double_quoted_string = "\"" < /[^"]*/ > "\"" { StringLiteral.new(text) }
  def _double_quoted_string

    _save = self.pos
    while true # sequence
      _tmp = match_string("\"")
      unless _tmp
        self.pos = _save
        break
      end
      _text_start = self.pos
      _tmp = scan(/\A(?-mix:[^"]*)/)
      if _tmp
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      _tmp = match_string("\"")
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  StringLiteral.new(text) ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_double_quoted_string unless _tmp
    return _tmp
  end

  Rules = {}
  Rules[:_eol] = rule_info("eol", "\"\\n\"")
  Rules[:_space] = rule_info("space", "(\" \" | \"\\t\" | eol)")
  Rules[:__hyphen_] = rule_info("-", "space*")
  Rules[:_root] = rule_info("root", "- \"grammar\" - rules:rules - \"end\" - { @grammar = Ast::Grammar.new(Array(rules)) }")
  Rules[:_rules] = rule_info("rules", "rule:first (- rule)*:rest { [first, *rest] }")
  Rules[:_rule] = rule_info("rule", "name:name - \"=\" - expression:expression { Rule.new(name, expression) }")
  Rules[:_name] = rule_info("name", "!\"end\" < /\\w+/ > { text.to_sym }")
  Rules[:_expression] = rule_info("expression", "sequence")
  Rules[:_sequence] = rule_info("sequence", "value:first (- value)*:rest { Sequence.new([first, *rest]) }")
  Rules[:_value] = rule_info("value", "(rule_reference | string)")
  Rules[:_rule_reference] = rule_info("rule_reference", "name:name !(- \"=\") { RuleReference.new(name) }")
  Rules[:_string] = rule_info("string", "(single_quoted_string | double_quoted_string)")
  Rules[:_single_quoted_string] = rule_info("single_quoted_string", "\"'\" < /[^']*/ > \"'\" { StringLiteral.new(text) }")
  Rules[:_double_quoted_string] = rule_info("double_quoted_string", "\"\\\"\" < /[^\"]*/ > \"\\\"\" { StringLiteral.new(text) }")
end
