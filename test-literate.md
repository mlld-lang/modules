@import { upper, trim } from "./core/string/string.md"

@text message = "  hello world  "
@text cleaned = @trim(@message)
@text shouting = @upper(@cleaned)

@add [[Original: "{{message}}"]]
@add [[Cleaned: "{{cleaned}}"]]
@add [[Shouting: {{shouting}}]]