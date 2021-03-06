defmodule Calc do

  def main() do
    try do 
    	input = String.trim(IO.gets(">"))
    	output = eval(input)
    	IO.puts(inspect(output))
    catch
	x -> IO.puts(Enum.join(["Error occured during parsing.", x], " "))
    end
    main()
  end

  def eval(a) do
    tokens1 = Regex.split(~r{(?<=[-+*/()])|(?=[-+*/()])},String.replace(a," ",""))
    tokens = Enum.filter(tokens1, fn(elem) -> elem != "" end)
    #tokens = String.split(a," ")
    #IO.puts(inspect(tokens1))
    ops=[]
    vals = []
    tpl1 = loop(tokens, ops, vals)
    ops = elem(tpl1, 0)
    vals = elem(tpl1, 1)
    tpl1 = process_parantheses(ops,vals)
    List.first(elem(tpl1,1))
  end

  defp loop([], ops, vals)do
    {ops, vals} 
  end

  defp loop([token|tokens], ops, vals) do
    tpl = process_token(token, ops, vals)
    ops = elem(tpl,0)
    vals = elem(tpl,1)
    tpl1 = loop(tokens, ops, vals)
    ops = elem(tpl1,0)
    vals = elem(tpl1,1)
    {ops, vals}
  end

  defp process_token(token, ops, vals) do
    cond do
      token == "(" ->
        ops = [token | ops]
	{ops,vals}
      token == "+" or token == "-" or token == "/" or token == "*" ->
        tpl = addops(token, ops, vals)
        ops = elem(tpl,0)
        vals = elem(tpl,1)
	{ops,vals}
      token == ")" ->
        tpl = process_parantheses(ops, vals)
        ops = Enum.slice(elem(tpl,0),1..length(elem(tpl,0)))
        {ops, elem(tpl,1)}
      true ->
        {ops, [int_parse(token) | vals]}
    end
    #{ops, vals}
  end

  defp process_parantheses([op | ops], vals) when op != "(" do
    [v2 | vals] = vals
    [v1 | vals] = vals
    x = apply_ops(op, v2, v1)
    #IO.puts(Enum.join([op," after apply ops", x, inspect(ops)], " "))
    vals = [x | vals]
    tpl = process_parantheses(ops,vals)
    ops = elem(tpl,0)
    vals = elem(tpl,1)
    {ops,vals}
  end

  defp process_parantheses(ops,vals) do
    #IO.puts(Enum.join([inspect(List.first(ops)), " terminate"], " "))
    {ops,vals}
  end

  defp addops(op, ops, vals) do
    #IO.puts(Enum.join([op, inspect(ops)], " "))
    cond do
      ops != [] and higher_precedence(op, Enum.at(ops,0)) ->
        #IO.puts(Enum.join(["Executing",op]," "))
        v2 = List.first(vals)
        vals = List.delete_at(vals,0)
        v1 = List.first(vals)
        vals = List.delete_at(vals,0)
        opr = List.first(ops)
        ops = List.delete_at(ops,0)
        x = apply_ops(opr, v2, v1)
        vals = [x | vals]
        ops = [op | ops]
        {ops, vals}
      true ->
        ops = [op | ops]
        {ops, vals}
     end
  end

  defp higher_precedence(op1,op2) do
    cond do
      op2 == "(" or op2 == ")" -> false
      ((op1 == "*" or op1 == "/") and (op2 == "+" or op2 == "-")) -> false
      true -> true
    end
  end

  defp int_parse(val) do
     elem(Integer.parse(val),0)
  end

  defp apply_ops(op, val2, val1) when op == "+" do
    (val1 + val2)
  end

  defp apply_ops(op, val2, val1) when op == "-" do
    (val1 - val2)
  end

  defp apply_ops(op, val2, val1) when op == "/" do
    cond do 
	(val2 == 0) -> throw("Error : Division by 0")
	true -> div(val1, val2)
    end
  end

  defp apply_ops(op, val2, val1) when op == "*" do
    (val1 * val2)
  end
end
