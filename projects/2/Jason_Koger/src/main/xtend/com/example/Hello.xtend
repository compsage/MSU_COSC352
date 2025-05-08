package com.example

class Hello {
    def static void main(String[] args) {
        if (args.length != 2) {
            println("Usage: java Hello <name> <number>")
            return
        }

        val name = args.get(0)
        val number = Integer::parseInt(args.get(1))

        for (i : 0 ..< number) {
            println("Hello " + name)
        }
    }
}
