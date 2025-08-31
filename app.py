from flask import Flask, render_template_string
import random

app = Flask(_name_)

ROWS = [
    '       ##       ',
    '      #{}--{}#      ',
    '     #{}----{}#     ',
    '    #{}------{}#    ',
    '   #{}------{}#   ',
    '    #{}------{}#    ',
    '     #{}----{}#     ',
    '      #{}--{}#      ',
    '       ##       ',
    '      #{}--{}#      ',
    '     #{}----{}#     ',
    '    #{}------{}#    ',
    '   #{}------{}#   ',
    '    #{}------{}#    ',
    '     #{}----{}#     ',
    '      #{}--{}#      '
]

rowIndex = 0  # Track animation position

@app.route("/")
def dna_frame():
    global rowIndex
    rowIndex = (rowIndex + 1) % len(ROWS)

    if ROWS[rowIndex].count('{}') == 0:
        frame = ROWS[rowIndex]
    else:
        pair = random.choice([('A','T'),('T','A'),('C','G'),('G','C')])
        frame = ROWS[rowIndex].format(pair[0], pair[1])

    return render_template_string(f"""
        <html>
            <head>
                <meta http-equiv="refresh" content="0.2">
                <style>
                    body {{ background-color: black; color: lime; font-family: monospace; text-align: center; }}
                    h1 {{ margin-top: 20%; }}
                </style>
            </head>
            <body>
                <h1>{frame}</h1>
            </body>
        </html>
    """)

if _name_ == "_main_":
    app.run(host="0.0.0.0", port=5000)