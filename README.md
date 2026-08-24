# Resume Manager

A helper tool for maintaining reusable LaTeX resume variants and creating
job-specific tailored resumes. The LaTeX template is based on Sourabh Bajaj's
[resume template](https://github.com/sb2nov/resume). Here is a sample resume I
wrote for Carl Johnson from GTA San Andreas:

![Resume template preview](template_preview.jpg)

### Motivation

Updating your resume based on the target job posting is an important step in
applying for jobs. However, manually copying, modifying, and renaming resume
files is repetitive, especially when different resume variants are used as the
basis for creating tailored versions. I built this repository to simplify this
process. I also updated the original template to reduce the number of commands,
and make their purpose easier to understand.

## Getting Started

Using this tool requires `make`, `latexmk`, and a LaTeX distribution such as
TeX Live or MacTeX.

The resumes are divided into two categories: `variants` and `tailored`.
`variants` are generic resumes for specific roles, such as `cpp_developer` or
`backend_engineer`. These variants are then selected to create a tailored resume
for a specific job posting, such as `carl_johnson_rockstar`.

Reusable resume variants live in the `variants/` directory, and tailored resume
versions are created in `tailored/` directory, by copying the related variant.
Generated PDFs are written to `build/`, and exported tailored PDFs are copied to
`out/`.

### Quick Start

```sh
git clone https://github.com/seinmon/resume-manager.git
cd resume-manager
make
make new-variant VARIANT=ios FROM=base
make new TAILORED=apple-ios VARIANT=ios
make TAILORED=apple-ios
make export TAILORED=apple-ios
```

### Repository Layout

```text
Makefile    Commands for creating, building, previewing, and cleaning resumes.
variants/   Reusable role-focused resumes.
tailored/   Job-specific resumes.
build/      Generated PDFs.
out/        Exported tailored PDFs.
```

Command names omit the `.tex` extension. For example, `make VARIANT=cpp` builds
`variants/cpp.tex`.

Build the default resume variant:

```sh
make
```

This builds `variants/base.tex` into `build/base.pdf`.

Build a different resume variant:

```sh
make VARIANT=cpp
```

Create a new reusable resume variant from an existing variant:

```sh
make new-variant VARIANT=ios FROM=base
```

Create a tailored resume from a reusable variant:

```sh
make new TAILORED=company-name VARIANT=ios
```

Build a tailored resume:

```sh
make TAILORED=company-name
```

Build and export a tailored resume PDF:

```sh
make export TAILORED=company-name
```

List available variants and tailored resumes:

```sh
make list
```

Continuously rebuild the selected resume for preview:

```sh
make preview
make preview VARIANT=cpp
make preview TAILORED=company-name
```

Remove auxiliary build files and the generated PDF for the selected resume:

```sh
make clean
```

Remove `build` and `out` directories:

```sh
make cleanall
```

## License

Licensed under MIT.
