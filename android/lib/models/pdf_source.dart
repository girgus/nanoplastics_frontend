class PDFSource {
  final String title;
  final int startPage;
  final int endPage;
  final String description;
  final String? pdfAssetPath; // Custom PDF asset path for non-main report PDFs

  PDFSource({
    required this.title,
    required this.startPage,
    required this.endPage,
    required this.description,
    this.pdfAssetPath,
  });
}

// Human Health Category
final List<PDFSource> humanHealthSources = [
  PDFSource(
    title: 'Poruchy autistického spektra a BPA',
    startPage: 92,
    endPage: 114,
    description: 'Central Systems (Brain & Nervous System)',
  ),
  PDFSource(
    title: 'Bioakumulace v lidském mozku',
    startPage: 92,
    endPage: 114,
    description: 'Central Systems (Brain & Nervous System)',
  ),
  PDFSource(
    title: 'Kardiovaskulární rizika (Ateromy)',
    startPage: 116,
    endPage: 119,
    description: 'Vitality & Tissues (Heart, Blood, Organs)',
  ),
  PDFSource(
    title: 'Nepříznivé výsledky porodů v USA (ftaláty)',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction & Development (Placenta, Fetus, Fertility)',
  ),
  PDFSource(
    title: 'Redukce příjmu MNP vařením vody',
    startPage: 71,
    endPage: 91,
    description: 'Filtration & Detox Systems (Kidney, Liver, Lymphatic)',
  ),
  PDFSource(
    title: 'Kvantové efekty a přenos protonů v buňkách',
    startPage: 92,
    endPage: 119,
    description: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
  ),
  PDFSource(
    title: 'Plasty v mužském semeni',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction & Development (Placenta, Fetus, Fertility)',
  ),
  PDFSource(
    title: 'Plasty v ženské folikulární tekutině',
    startPage: 120,
    endPage: 131,
    description: 'Reproduction & Development (Placenta, Fetus, Fertility)',
  ),
  PDFSource(
    title: 'Kontaminace mléčných výrobků',
    startPage: 70,
    endPage: 91,
    description: 'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
  ),
  PDFSource(
    title: 'Expozice ftalátům a rakovina u dětí',
    startPage: 92,
    endPage: 119,
    description: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
  ),
];

// Earth Pollution Category
final List<PDFSource> earthPollutionSources = [
  PDFSource(
    title: 'Globální ztráty fotosyntézy',
    startPage: 31,
    endPage: 44,
    description:
        'Flora, Fauna & Soil Biota (Terrestrial Ecosystems, Photosynthesis)',
  ),
  PDFSource(
    title: 'Růst fragmentů v tichomořské skvrně',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination, Ocean Impacts)',
  ),
  PDFSource(
    title: 'Emise plastů z oceánu do atmosféry',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination, Ocean Impacts)',
  ),
  PDFSource(
    title: 'Překonávání hematoencefalické bariéry',
    startPage: 92,
    endPage: 119,
    description: 'Physical Properties (Polymer Degradation, Persistence)',
  ),
  PDFSource(
    title: 'Tvorba ledu v atmosféře pomocí MNP',
    startPage: 23,
    endPage: 30,
    description:
        'Atmosphere & Global Water Cycle (Airborne Plastics, Precipitation)',
  ),
  PDFSource(
    title: 'MNP v mracích a vliv na srážky',
    startPage: 23,
    endPage: 30,
    description:
        'Atmosphere & Global Water Cycle (Airborne Plastics, Precipitation)',
  ),
  PDFSource(
    title: 'Acidifikace oceánů rozkladem plastů',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination, Ocean Impacts)',
  ),
  PDFSource(
    title: 'Kontaminace nejhlubších částí oceánu',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination, Ocean Impacts)',
  ),
  PDFSource(
    title: 'Zánik korálových útesů',
    startPage: 45,
    endPage: 66,
    description: 'World Ocean (Marine Contamination, Ocean Impacts)',
  ),
  PDFSource(
    title: 'Geofyzikální zlom v roce 1995',
    startPage: 68,
    endPage: 69,
    description: 'Magnetic Field & Earth\'s Core (Geophysical Impacts)',
  ),
];

// Special Water Abilities Category
final List<PDFSource> waterAbilitiesSources = [
  PDFSource(
    title: 'Special Water Abilities - Czech',
    startPage: 1,
    endPage: 6,
    description: 'Water Properties & Quantum Effects',
    pdfAssetPath: 'assets/docs/CS_WATER_compressed.pdf',
  ),
  PDFSource(
    title: 'Special Water Abilities - English',
    startPage: 1,
    endPage: 6,
    description: 'Water Properties & Quantum Effects',
    pdfAssetPath: 'assets/docs/EN_WATER_compressed.pdf',
  ),
];
