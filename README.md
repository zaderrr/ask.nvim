# Code query #
Designed for brief explanations or questions for a code agent. (Currently only claude)

The addiction of being able to accept a 10,000 change from an agent got too much.
I realised that they want you to accept the changes, even if not prompted to make changes, and if you have always accept enabled, they will just run wild.

This plugin just provides a basic one line prompt in order to limit discussion. 

Coding agents are great for helping you to understand certain code or finding one line index out of ranges etc.
So I made this (with claude, ironic) to limit interaction to explanations of code & queries like "How do I read files in python" without context of your entire root directory being piped in.

## Basic usage ##
`:CQ <prompt>`
`:CQ How do I write a for loop in lua?`

`:'<,'>CQV <prompt>`
`:'<,'>CQV what does this function do?`

