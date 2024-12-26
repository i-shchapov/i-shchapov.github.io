#let cvdata = yaml("cv.yml")
#let personal = cvdata.identity

#set page(
  "a4", 
  margin: (left: 1.5cm, right: 1.5cm, top: 2cm, bottom: 1.5cm),
  header: context 
    if here().page() == 1 {
    } else {
    grid(
      columns: (2fr, 2fr),
      rows: auto,
      align: (left, right),
      [#personal.name],
      [#counter(page).display("1",both: false)]
    )
  }
)
#set text(font: "EB Garamond", size: 11pt)
#show link: underline

#show heading.where(
  level: 1
): it => [
  #set align(center)
  #set text(20pt, weight: "bold")
  #block(smallcaps(it.body))
]

#show heading.where(
  level: 2
): it => [
  #set text(11pt, weight: "regular")
  #block(smallcaps(it.body))
]

#let toplevel_block(header, contents) = {
  block(
    grid(
      columns: (16%, 1fr),
      gutter: 16pt,
      [== #header],
      [#contents]
    ),
    spacing: 12pt
  )
}

#let jobtitle(title) = [- #title]

#let nonblank(dict, field) = {
  field in dict.keys() and dict.at(field) != ""
}

#let employer_block(institution, location, positions) = {
  grid(
    columns: (60%, 1fr), // Title on the left, Dates on the right
    rows: auto, // Automatically adjust row height
    gutter: 6pt, // Spacing between columns
    align: (left, right), // Align title to the left, dates to the right
    // Render institution and location in the first row
    [#strong(institution)], // Bold the institution name
    [#text(location)], // Render the location text
    ..for (title, dates) in positions {
      (title, dates) // Render job title and dates without a list
    }
  )
}


// Define a command to render a single non-academic appointment
#let non_academic_appointment(title, employer, dates) = {
  // Use a grid to align title/dates and employer
  grid(
    columns: (80%, 1fr), // Adjust column widths: title-left, dates-right
    rows: auto, // Automatically adjust row height
    gutter: 6pt, // Spacing between columns
    align: (left, right), // Align title left and dates right
    // First row: Title (left) and Dates (right)
    [#text(title)],
    [#text(dates)],
    // Second row: Employer in bold across both columns
    [#strong(employer)], 
    []
  )
}

#let reference_block(name, position, institution, email, url) = {
  grid(
    columns: (1fr, 1fr),  // Two equal-width columns
    rows: auto,
    gutter: 6pt,
    align: (left, left),
    [
      #link(url, strong(name))\ // Make name bold and link if URL is provided
      #position\
      #institution\
      #link("mailto:" + email, email)  // Make email clickable
    ]
  )
}

#let my_paper(d) = {
  block([
    #if nonblank(d, "cv_url") [
      #link(d.cv_url, strong(d.title))\  // Link the paper title to the cv_url
    ] else [
      *#d.title* \ // If no cv_url is provided, just print the title
    ]
    #d.coauthors
    #if nonblank(d, "status") [
      \
      _#d.status _
    ]
  ])
}

#let remove_repeated_dates(entries, datefield: "year") = {
  let sort_by(x) = x.at(datefield)
  entries = entries.sorted(key: sort_by).rev()
   let current_year = 0
   for (i,entry) in entries.enumerate() {
     if entry.at(datefield) == current_year {
       // do not print the year
       entries.at(i).at(datefield) = ""
     }
     current_year = entry.at(datefield)
   }
   entries
}

#let grant_text(grant) = [
  // Display the grant name
  #grant.name
  // Optionally display the grant amount in parentheses
  #if "amount" in grant.keys() and grant.amount != "" [ (#grant.amount)]
  // Optionally display corecipients on a new line
  #if "corecipients" in grant.keys() and grant.corecipients != "" [
    \ 
    #h(1em) with #grant.corecipients
  ]
  \
]

#let grants_block(grants) = {
  grid(
    columns: (80%, 1fr), // Name/Details on the left, Date on the right
    rows: auto, // Automatically adjust row height
    gutter: 6pt, // Spacing between columns
    align: (left, right), // Align grant details left and date right
    ..for grant in grants {
      (grant_text(grant), grant.date)
    }
  )
}

#let teaching_block(d) = {
  [
    #grid(
      columns: (80%, 1fr),
      rows: auto,
      gutter: 6pt,
      align: (left, right),
      [#strong(d.institution)],   // Apply bold to the institution
      [#d.dates],
      ..for (title, level) in d.courses {
        ([ - #title (#level)], "")
      }
    )
  ]
}

#let presentations_block(paper_title, presentations) = block[
  *#paper_title*
  #grid(
    columns: (70%, 15%, 1fr),
    rows: auto,
    gutter: 6pt,
    align: (left, left, right),
    ..for p in presentations {
      let descr = ""
      if nonblank(p,"coauthor") {descr = descr + "*"}
      descr = descr + p.venue + ", " + p.location
      (descr, p.type, p.date)
    }
  )
]

#let unbreaking(..args) = args.pos().map(grid.cell.with(breakable: false))

#let discussions_block(discussions) = {
  set grid.cell(breakable: false)
  grid(
      columns: (80%, 1fr),
      rows: auto,
      gutter: 10pt,
      align: (left, right),
      ..for d in discussions {
        let dstr = [#d.title, by #d.authors\
                _#d.venue, #d.location _]
        (dstr, d.date)
      }
    )
  }

#let service_block(type, entries) = block[
  #type \
  _#entries.join("; ")_
]

#let advising_block(header, advisees) = [
  *#header*:
  #grid(
    columns: (85%, 1fr),
    rows: auto,
    gutter: 10pt,
    align: (left, right),
    ..for a in advisees {
      let astr = [
        #a.name, "#a.title" \
        #h(1em) Placement: #a.placement.role, #a.placement.institution, #a.placement.location
      ]
      (astr, a.date)
    }
  )
]

#let two_column_block(array_of_dicts, sep: " ") = grid(
  columns: (100%, 2fr),
  rows: auto,
  gutter: 6pt,
  align: (left, right),
  ..for d in array_of_dicts {
      let v = d.values()
      let date = v.pop()
      (v.join(sep), date)
  }
)

// Name

= #personal.name

#line(length: 100%)

// Contact Info
#grid(
  columns: (60%, 1fr),
  
  [#personal.address.join("\n") \
   #personal.phone \
   #link("mailto:" + personal.email) ],

  align(right)[
    
    #link(personal.website) \
    #for (url, network) in personal.profiles [
      #link(url)[#network] \
    ]
  ]
)

// Academic Positions

#toplevel_block("Education",   
  for (institution, location, degrees) in cvdata.education {
    employer_block(institution, location, degrees)
  })


#let references = cvdata.references

#let left_column = references.filter(reference => reference.column == 1)
#let right_column = references.filter(reference => reference.column == 2)

#toplevel_block("References", 
  grid(
    columns: (7cm, 15cm),   // Two columns
    // Left column
    [ 
      #for reference in left_column {
        reference_block(reference.name, reference.position, reference.institution, reference.email, reference.url)
      }
    ],
    // Right column
    [ 
      #for reference in right_column {
        reference_block(reference.name, reference.position, reference.institution, reference.email, reference.url)
      }
    ]
  )
)

#toplevel_block("Research Interests", [Monetary macroeconomics, Macro-finance, financial frictions])

#toplevel_block("Publications", for p in cvdata.publications {
  if nonblank(p,"status") {p.journal = p.status}
  my_paper(p)
})

#toplevel_block("Job Market Paper", for p in cvdata.JMP {
  if nonblank(p,"status") {p.journal = p.status}
  my_paper(p)
})

#toplevel_block("Working Papers", for p in cvdata.working-papers {
  if nonblank(p,"status") {p.journal = p.status}
  my_paper(p)
})

#toplevel_block("Works in Progress", for p in cvdata.works-in-progress {
  my_paper(p)
})

#toplevel_block("Awards", 
  grid(
    columns: (80%, 1fr), // Left column: award name/details, Right column: date
    rows: auto,
    gutter: 6pt,
    align: (left, right),
    ..for award in cvdata.awards {
      (grant_text(award), award.date)
    }
  )
)

#toplevel_block("Teaching Experience", 
for t in cvdata.teaching {
  teaching_block(t)
}
)

#toplevel_block("Non-Academic Appointments", 
  for a in cvdata.non_academic_appointments {
    non_academic_appointment(a.title, a.employer, a.dates)
  }
)

#toplevel_block("Competences", 
  [Languages: English (C2), French (C1), Russian (native); \
  Macro modelling: MatLab, Dynare, Julia, GDSGE; \
  Econometrics: MatLab, Julia, R, STATA, EViews, Ox Metrics.]
)