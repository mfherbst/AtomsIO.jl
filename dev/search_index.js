var documenterSearchIndex = {"docs":
[{"location":"saveload/#Saving-and-loading-files","page":"Saving and loading files","title":"Saving and loading files","text":"","category":"section"},{"location":"saveload/","page":"Saving and loading files","title":"Saving and loading files","text":"The following functions form the API for saving and loading files:","category":"page"},{"location":"saveload/","page":"Saving and loading files","title":"Saving and loading files","text":"AtomsIO.load_system\nAtomsIO.save_system\nAtomsIO.load_trajectory\nAtomsIO.save_trajectory","category":"page"},{"location":"saveload/#AtomsIO.load_system","page":"Saving and loading files","title":"AtomsIO.load_system","text":"load_system([parser], file::AbstractString; kwargs...)\nload_system([parser], file::AbstractString, index; kwargs...)\n\nRead an AtomsBase-compatible system from file. If file contains more than one structure the last entry is returned. If index is specified this indexes into the list of structures and returns the respective system.\n\nBy default AtomsIO picks an appropriate parser for the specified file format automatically. A specific parser (such as AtomsIO.ExtxyzParser or AtomsIO.ChemfilesParser) can be enforced by using it as the first argument. Some parsers support additional keyword arguments. E.g. AseParser supports the format argument to overwrite the ASE-internal selection of an input / output format.\n\n\n\n\n\n","category":"function"},{"location":"saveload/#AtomsIO.save_system","page":"Saving and loading files","title":"AtomsIO.save_system","text":"save_system([parser], file::AbstractString, system::AbstractSystem; kwargs...)\n\nSave an AtomsBase-compatible system to the file. By default AtomsIO picks an appropriate parser for the specified file format automatically. A specific parser (such as AtomsIO.ExtxyzParser or AtomsIO.ChemfilesParser) can be enforced by using it as the first argument. Some parsers support additional keyword arguments. E.g. AseParser supports the format argument to overwrite the ASE-internal selection of an input / output format.\n\n\n\n\n\n","category":"function"},{"location":"saveload/#AtomsIO.load_trajectory","page":"Saving and loading files","title":"AtomsIO.load_trajectory","text":"load_trajectory([parser], file::AbstractString; kwargs...)\n\nRead a trajectory from a file and return a vector of AtomsBase-compatible structures. Providing a parser overwrites the automatic AtomsIO selection.\n\n\n\n\n\n","category":"function"},{"location":"saveload/#AtomsIO.save_trajectory","page":"Saving and loading files","title":"AtomsIO.save_trajectory","text":"save_trajectory([parser], file::AbstractString, systems::AbstractVector; kwargs...)\n\nSave a trajectory given as a list of AtomsBase-compatible systems to a file. Providing a parser overwrites the automatic AtomsIO selection.\n\n\n\n\n\n","category":"function"},{"location":"saveload/","page":"Saving and loading files","title":"Saving and loading files","text":"See File Formats for the list of parsers.","category":"page"},{"location":"file_formats/#File-Formats","page":"File Formats","title":"File Formats","text":"","category":"section"},{"location":"file_formats/","page":"File Formats","title":"File Formats","text":"This page provides an overview of parsing libraries interfaced from AtomsIO and an (incomplete) list of file formats they support. The parsing libraries are listed in order of preference, i.e. the order in which AtomsIO.load_system, AtomsIO.save_system, AtomsIO.load_trajectory and AtomsIO.save_trajectory will attempt the parsing libraries until one flags that it supports parsing/writing such a format. If a file format is thus listed in combination with multiple parsers, the above methods will only ever consult the first of the parser libraries. Note that one can always overwrite the automatic AtomsIO selection by providing the parser library explicitly as first argument.","category":"page"},{"location":"file_formats/","page":"File Formats","title":"File Formats","text":"AtomsIO also features an integration with a number of python libraries (such as ASE) to support parsing a wide range of atomic structure files. These python-based are not enabled by default to avoid introducing Python dependencies for down-stream code when this can be avoided. Python-dependent code paths can be activated by a simple using AtomsIOPython before calling load_system or save_system or similar. This should automatically install all required python dependencies.","category":"page"},{"location":"file_formats/","page":"File Formats","title":"File Formats","text":"note: Note\nUnfortunately atomistic file formats are usually horribly underspecified and generally not all details are supported in all formats. Common examples are that some file formats are unable to store velocity information, others only work for non-periodic systems etc. Therefore even though we try to be careful in AtomsIO, it frequently happens that some information is lost when writing a system to disk. An additional caveat is that the way how particular atomistic properties are mapped to individual data fields of a file format is not standardised amongst parser libraries. To recover a system as closely as possible, it is thus advisable to choose the same parser library for writing and reading a file.","category":"page"},{"location":"file_formats/","page":"File Formats","title":"File Formats","text":"tip: Tip\nFor the reasons mentioned above a good long-term storage format (in the eyes of the AtomsIO authors) is the extended XYZ format via the AtomsIO.ExtxyzParser. This format and parser has a well-documented specification and moreover leads to a human-readable plain-text file.","category":"page"},{"location":"file_formats/","page":"File Formats","title":"File Formats","text":"The following list all currently available parsers, in the order they are tried (top to bottom):","category":"page"},{"location":"file_formats/","page":"File Formats","title":"File Formats","text":"AtomsIO.ExtxyzParser\nAtomsIO.XcrysdenstructureformatParser\nAtomsIO.ChemfilesParser\nAtomsIOPython.AseParser","category":"page"},{"location":"file_formats/#AtomsIO.ExtxyzParser","page":"File Formats","title":"AtomsIO.ExtxyzParser","text":"Parse or write file using ExtXYZ\n\nSupported formats:\n\nXYZ and extxyz files\n\n\n\n\n\n","category":"type"},{"location":"file_formats/#AtomsIO.XcrysdenstructureformatParser","page":"File Formats","title":"AtomsIO.XcrysdenstructureformatParser","text":"Parse or write file using XCrySDenStructureFormat.\n\nSupported formats:\n\nXSF and AXSF atomic structure files. These are the files typically used by the XCrySDen visualisation program.\n\nnote: Format has been dropped in AtomsIO 0.3\nThis file format has been supported in earlier versions of AtomsIO, but is now dropped as the implementing packages lack a maintainer and no longer function with the most recent version of AtomsBase. In case of interest, see the draft PR, which can be completed to re-enable support.\n\n\n\n\n\n","category":"type"},{"location":"file_formats/#AtomsIO.ChemfilesParser","page":"File Formats","title":"AtomsIO.ChemfilesParser","text":"Parse or write file using Chemfiles.\n\nSupported formats:  \n\nCIF files\nGromacs / LAMMPS / Amber trajectory files\n\n\n\n\n\n","category":"type"},{"location":"file_formats/#AtomsIOPython.AseParser","page":"File Formats","title":"AtomsIOPython.AseParser","text":"Requires AtomsIOPython to be loaded. Parse or write files using the Atomistic Simulation Environment (ASE) via ASEconvert.\n\nSupported formats:  \n\nCIF files\nQuantum Espresso / ABINIT / VASP input files\nASE trajectory files\nXYZ and extxyz files\n\n\n\n\n\n","category":"type"},{"location":"#AtomsIO","page":"Home","title":"AtomsIO","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Standard package for reading and writing atomic structures represented as an AtomsBase-compatible data structure. AtomsIO currently integrates with","category":"page"},{"location":"","page":"Home","title":"Home","text":"Chemfiles\nExtXYZ\nASEconvert (respectively ASE)","category":"page"},{"location":"","page":"Home","title":"Home","text":"and supports all file formats any of these packages support (see their respective documentation). This includes","category":"page"},{"location":"","page":"Home","title":"Home","text":"Crystallographic Information Framework (CIF) files\nQuantum Espresso / ABINIT / VASP input files\nASE / Gromacs / LAMMPS / Amber trajectory files\nXYZ and extxyz files","category":"page"},{"location":"","page":"Home","title":"Home","text":"For more details see Saving and loading files and File Formats.","category":"page"},{"location":"","page":"Home","title":"Home","text":"note: Python-based parsers\nReading / writing some formats relies on parser libraries from third-party Python packages. To avoid introducing Python dependencies in all packages employing AtomsIO the additional package AtomsIOPython needs to be loaded to make these parsers available. See File Formats for more details.","category":"page"},{"location":"","page":"Home","title":"Home","text":"note: Formats supported in earlier versions of AtomsIO\nThese file formats were supported in earlier versions of AtomsIO, but are now dropped as the implementing packages lack a maintainer and no longer function with the most recent version of AtomsBase.XSF (XCrySDen) structure and trajectory files were supported using the XCrySDenStructureFormat package. In case of interest, see the draft PR, which can be completed to re-enable support.","category":"page"},{"location":"#Usage-example","page":"Home","title":"Usage example","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using AtomsIO        # Enables only Julia-based parsers\nusing AtomsIOPython  # Enable python-based parsers as well\n\n# Load system from a cif file ... by default uses ASE.\n# Returns an AtomsBase-compatible system.\nsystem = load_system(\"Si.cif\")\n\n# The system can now be used with any package supporting AtomsBase,\n# e.g. display unit cell, positions and chemical formula ...\n@show bounding_box(system)\n@show position(system)\n@show chemical_formula(system)\n\n# ... or do a DFT calculation using DFTK.\nusing DFTK\nusing PseudoPotentialData\npseudopotentials = PseudoFamily(\"dojo.nc.sr.lda.v0_4_1.oncvpsp3.standard.upf\")\nmodel  = model_DFT(system; pseudopotentials)\nbasis  = PlaneWaveBasis(model; Ecut=15, kgrid=(3, 3, 3))\nscfres = self_consistent_field(basis);\n\n# We could also load a whole trajectory (as a list of systems):\ntrajectory = load_trajectory(\"mdrun.traj\")\n\n# ... or only the 6-th structure:\nlast_system = load_system(\"mdrun.traj\", 6)","category":"page"}]
}
