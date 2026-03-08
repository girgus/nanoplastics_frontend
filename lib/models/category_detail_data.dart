import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';

class CategoryDetailData {
  final String categoryKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final Color glowColor;
  final List<DetailEntry> entries;
  final List<EvidenceSection> evidenceSections;
  final List<SourceLink>? sourceLinks;

  const CategoryDetailData({
    required this.categoryKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.glowColor,
    required this.entries,
    required this.evidenceSections,
    this.sourceLinks,
  });

  int get evidenceStudyCount => evidenceSections.fold(
      0, (total, section) => total + section.studies.length);

  List<EvidenceStudy> get allEvidenceStudies => evidenceSections
      .expand((section) => section.studies)
      .toList(growable: false);

  List<EvidenceStudy> featuredStudies([int count = 3]) =>
      allEvidenceStudies.take(count).toList(growable: false);
}

class DetailEntry {
  final String highlight;
  final String description;
  final List<String>? bulletPoints;
  final int? pdfStartPage;
  final int? pdfEndPage;
  final String? pdfCategory;

  const DetailEntry({
    required this.highlight,
    required this.description,
    this.bulletPoints,
    this.pdfStartPage,
    this.pdfEndPage,
    this.pdfCategory,
  });
}

class EvidenceSection {
  final String id;
  final String title;
  final String? description;
  final List<EvidenceStudy> studies;

  const EvidenceSection({
    required this.id,
    required this.title,
    this.description,
    required this.studies,
  });
}

class EvidenceStudy {
  final String title;
  final String authorsShort;
  final String journal;
  final int year;
  final String url;
  final String? doiOrPubMed;
  final String? studyType;
  final String? summary;
  final List<String> tags;

  const EvidenceStudy({
    required this.title,
    required this.authorsShort,
    required this.journal,
    required this.year,
    required this.url,
    this.doiOrPubMed,
    this.studyType,
    this.summary,
    this.tags = const [],
  });
}

class SourceLink {
  final String title;
  final String source;
  final String url;
  final String? pdfAssetPath;
  final int? pdfStartPage;
  final int? pdfEndPage;

  const SourceLink({
    required this.title,
    required this.source,
    required this.url,
    this.pdfAssetPath,
    this.pdfStartPage,
    this.pdfEndPage,
  });
}

EvidenceStudy _study({
  required String title,
  required String authorsShort,
  required String journal,
  required int year,
  required String url,
  String? doiOrPubMed,
  String? studyType,
  String? summary,
  List<String> tags = const [],
}) {
  return EvidenceStudy(
    title: title,
    authorsShort: authorsShort,
    journal: journal,
    year: year,
    url: url,
    doiOrPubMed: doiOrPubMed,
    studyType: studyType,
    summary: summary,
    tags: tags,
  );
}

List<SourceLink> _toSourceLinks(List<EvidenceSection> sections) {
  return sections
      .expand((section) => section.studies)
      .map(
        (study) => SourceLink(
          title: study.title,
          source: '${study.journal} (${study.year})',
          url: study.url,
        ),
      )
      .toList(growable: false);
}

class CategoryDetailDataFactory {
  static List<CategoryDetailData> all(AppLocalizations l10n) => [
        centralSystems(l10n),
        filtrationDetox(l10n),
        vitalityTissues(l10n),
        reproduction(l10n),
        entryGates(l10n),
        physicalAttack(l10n),
        worldOcean(l10n),
        atmosphere(l10n),
        florFauna(l10n),
        magneticField(l10n),
        planetEntryGates(l10n),
        physicalProperties(l10n),
      ];

  static CategoryDetailData centralSystems(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'aggressiveness',
        title: l10n.detailCentralSystemsEntry1Highlight,
        description: l10n.detailCentralSystemsEntry1Desc,
        studies: [
          _study(
            title:
                'Micro- and Nanoplastics Breach the Blood-Brain Barrier (BBB): Biomolecular Corona\'s Role Revealed',
            authorsShort: 'Kopatz et al.',
            journal: 'Nanomaterials',
            year: 2023,
            url: 'https://doi.org/10.3390/nano13081404',
            doiOrPubMed: 'doi:10.3390/nano13081404',
            studyType: 'Mechanistic study',
            summary:
                'Shows how biomolecular corona formation supports transport across the blood-brain barrier.',
            tags: ['mechanism', 'brain', 'barrier'],
          ),
          _study(
            title:
                'Environmental exposure enhances the internalization of microplastic particles into cells',
            authorsShort: 'Ramsperger et al.',
            journal: 'Science Advances',
            year: 2020,
            url: 'https://www.science.org/doi/10.1126/sciadv.abd1211',
            doiOrPubMed: 'doi:10.1126/sciadv.abd1211',
            studyType: 'Cell study',
            summary:
                'Demonstrates rapid cellular uptake after environmental conditioning of plastic particles.',
            tags: ['cellular uptake', 'mechanism'],
          ),
          _study(
            title:
                'Interfacial Interactions between Nanoplastics and Biological Systems: toward an Atomic and Molecular Understanding of Plastics-Driven Biological Dyshomeostasis',
            authorsShort: 'Karim et al.',
            journal: 'ACS Applied Materials and Interfaces',
            year: 2024,
            url: 'https://pubs.acs.org/doi/10.1021/acsami.4c03008',
            doiOrPubMed: 'doi:10.1021/acsami.4c03008',
            studyType: 'Mechanistic review',
            summary:
                'Connects surface interactions, corona formation, and downstream biological disruption.',
            tags: ['review', 'surface chemistry', 'mechanism'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'brain-penetration',
        title: l10n.detailCentralSystemsEntry2Highlight,
        description: l10n.detailCentralSystemsEntry2Desc,
        studies: [
          _study(
            title: 'Bioaccumulation of microplastics in decedent human brains',
            authorsShort: 'Nihart et al.',
            journal: 'Nature Medicine',
            year: 2025,
            url: 'https://www.nature.com/articles/s41591-024-03453-1',
            doiOrPubMed: 'PMID:39901044',
            studyType: 'Human tissue study',
            summary:
                'Reports brain accumulation in decedent tissue with higher burdens than liver or kidney.',
            tags: ['human study', 'brain', 'bioaccumulation'],
          ),
          _study(
            title:
                'Microplastics in the bloodstream can induce cerebral thrombosis by causing cell obstruction and lead to neurobehavioral abnormalities',
            authorsShort: 'Huang et al.',
            journal: 'Science Advances',
            year: 2025,
            url: 'https://www.science.org/doi/10.1126/sciadv.adr8243',
            doiOrPubMed: 'doi:10.1126/sciadv.adr8243',
            studyType: 'In vivo study',
            summary:
                'Links circulating microplastics with thrombosis and neurologic changes in vivo.',
            tags: ['circulation', 'neuro', 'vascular'],
          ),
          _study(
            title: 'Microplastics in the Olfactory Bulb of the Human Brain',
            authorsShort: 'Amato-Lourenco et al.',
            journal: 'JAMA Network Open',
            year: 2024,
            url:
                'https://jamanetwork.com/journals/jamanetworkopen/fullarticle/2823787',
            doiOrPubMed: 'doi:10.1001/jamanetworkopen.2024.3787',
            studyType: 'Human tissue study',
            summary:
                'Finds microplastics in the human olfactory bulb, supporting inhalation-related entry routes.',
            tags: ['human study', 'olfactory', 'brain'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_central',
      title: l10n.detailCentralSystemsTitle,
      subtitle: l10n.detailCentralSystemsSubtitle,
      icon: Icons.psychology_outlined,
      themeColor: AppColors.neonCyan,
      glowColor: AppColors.neonCyanGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailCentralSystemsEntry1Highlight,
          description: l10n.detailCentralSystemsEntry1Desc,
          bulletPoints: [
            l10n.detailCentralSystemsEntry1Bullet1,
            l10n.detailCentralSystemsEntry1Bullet2,
            l10n.detailCentralSystemsEntry1Bullet3,
          ],
          pdfStartPage: 92,
          pdfEndPage: 114,
          pdfCategory: 'Central Systems (Brain & Nervous System)',
        ),
        DetailEntry(
          highlight: l10n.detailCentralSystemsEntry2Highlight,
          description: l10n.detailCentralSystemsEntry2Desc,
          pdfStartPage: 92,
          pdfEndPage: 114,
          pdfCategory: 'Central Systems (Brain & Nervous System)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData filtrationDetox(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'gut-disruption',
        title: l10n.detailFiltrationDetoxEntry1Highlight,
        description: l10n.detailFiltrationDetoxEntry1Desc,
        studies: [
          _study(
            title:
                'The triple exposure nexus of microplastic particles, plastic-associated chemicals, and environmental pollutants from a human health perspective',
            authorsShort: 'Alijagic et al.',
            journal: 'Environment International',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0160412024003222?via%3Dihub',
            studyType: 'Review',
            summary:
                'Frames gut and detox burden as a combined exposure problem involving particles, additives, and co-pollutants.',
            tags: ['review', 'gut', 'exposure'],
          ),
          _study(
            title:
                'Microplastics and human health: unveiling the gut microbiome disruption and chronic disease risks',
            authorsShort: 'Bora et al.',
            journal: 'Frontiers in Cellular and Infection Microbiology',
            year: 2024,
            url:
                'https://www.frontiersin.org/journals/cellular-and-infection-microbiology/articles/10.3389/fcimb.2024.1492759/full?trk=public_post_comment-text',
            studyType: 'Review',
            summary:
                'Summarizes gut barrier disruption, dysbiosis, and downstream chronic disease pathways.',
            tags: ['review', 'gut', 'microbiome'],
          ),
          _study(
            title:
                'Drinking Boiled Tap Water Reduces Human Intake of Nanoplastics and Microplastics',
            authorsShort: 'Yu et al.',
            journal: 'Environmental Science and Technology Letters',
            year: 2024,
            url: 'https://pubs.acs.org/doi/10.1021/acs.estlett.4c00081',
            doiOrPubMed: 'doi:10.1021/acs.estlett.4c00081',
            studyType: 'Exposure mitigation study',
            summary:
                'Provides a practical exposure-reduction finding relevant to ingestion pathways.',
            tags: ['exposure', 'drinking water', 'mitigation'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'organ-accumulation',
        title: l10n.detailFiltrationDetoxEntry2Highlight,
        description: l10n.detailFiltrationDetoxEntry2Desc,
        studies: [
          _study(
            title: 'Bioaccumulation of microplastics in decedent human brains',
            authorsShort: 'Nihart et al.',
            journal: 'Nature Medicine',
            year: 2025,
            url: 'https://www.nature.com/articles/s41591-024-03453-1',
            doiOrPubMed: 'PMID:39901044',
            studyType: 'Human tissue study',
            summary:
                'Includes organ burden comparisons that highlight accumulation beyond the gut.',
            tags: ['human study', 'organs', 'bioaccumulation'],
          ),
          _study(
            title:
                'Microplastics: A threat for developing and repairing organs?',
            authorsShort: 'Hofstede et al.',
            journal: 'Cambridge Prisms: Plastics',
            year: 2023,
            url:
                'https://www.cambridge.org/core/journals/cambridge-prisms-plastics/article/microplastics-a-threat-for-developing-and-repairing-organs/F4683C00B4F24CAF7506A467F1037CF5',
            studyType: 'Review',
            summary:
                'Reviews inflammation, oxidative stress, and impaired organ repair under microplastic exposure.',
            tags: ['review', 'organs', 'inflammation'],
          ),
          _study(
            title:
                'Recent insights into uptake, toxicity, and molecular targets of microplastics and nanoplastics relevant to human health impacts',
            authorsShort: 'Khan and Jia',
            journal: 'iScience',
            year: 2023,
            url:
                'https://www.sciencedirect.com/science/article/pii/S2589004223001384',
            doiOrPubMed: 'PMID:36818296',
            studyType: 'Review',
            summary:
                'Summarizes cellular uptake, liver and kidney burden, and molecular toxicity targets.',
            tags: ['review', 'toxicity', 'organs'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_detox',
      title: l10n.detailFiltrationDetoxTitle,
      subtitle: l10n.detailFiltrationDetoxSubtitle,
      icon: Icons.water_drop_outlined,
      themeColor: AppColors.neonLime,
      glowColor: AppColors.neonLimeGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailFiltrationDetoxEntry1Highlight,
          description: l10n.detailFiltrationDetoxEntry1Desc,
          bulletPoints: [
            l10n.detailFiltrationDetoxEntry1Bullet1,
            l10n.detailFiltrationDetoxEntry1Bullet2,
            l10n.detailFiltrationDetoxEntry1Bullet3,
          ],
          pdfStartPage: 71,
          pdfEndPage: 91,
          pdfCategory: 'Filtration & Detox Systems (Kidney, Liver, Lymphatic)',
        ),
        DetailEntry(
          highlight: l10n.detailFiltrationDetoxEntry2Highlight,
          description: l10n.detailFiltrationDetoxEntry2Desc,
          pdfStartPage: 71,
          pdfEndPage: 91,
          pdfCategory: 'Filtration & Detox Systems (Kidney, Liver, Lymphatic)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData vitalityTissues(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'mitochondrial-dysfunction',
        title: l10n.detailVitalityTissuesEntry1Highlight,
        description: l10n.detailVitalityTissuesEntry1Desc,
        studies: [
          _study(
            title:
                'Microplastics and Nanoplastics in Atheromas and Cardiovascular Events',
            authorsShort: 'Marfella et al.',
            journal: 'The New England Journal of Medicine',
            year: 2024,
            url: 'https://www.nejm.org/doi/10.1056/NEJMoa2309822',
            doiOrPubMed: 'PMID:38446676',
            studyType: 'Human cohort study',
            summary:
                'Links plaque-contained microplastics with elevated risk of major cardiovascular events.',
            tags: ['human study', 'cardiovascular', 'bloodstream'],
          ),
          _study(
            title:
                'Microplastics in three types of human arteries detected by pyrolysis-gas chromatography/mass spectrometry (Py-GC/MS)',
            authorsShort: 'Liu et al.',
            journal: 'Journal of Hazardous Materials',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0304389424004345?via%3Dihub',
            studyType: 'Human tissue study',
            summary:
                'Detects plastic residues in multiple artery types, reinforcing vascular exposure concerns.',
            tags: ['human study', 'arteries', 'vascular'],
          ),
          _study(
            title: 'Journey of micronanoplastics with blood components',
            authorsShort: 'Rajendran and Chandrasekaran',
            journal: 'RSC Advances',
            year: 2023,
            url:
                'https://pubs.rsc.org/en/content/articlelanding/2023/ra/d3ra05620a',
            studyType: 'Review',
            summary:
                'Explains interactions between particles and blood components during circulation.',
            tags: ['review', 'blood', 'mechanism'],
          ),
          _study(
            title:
                'Mitochondria as a target of micro- and nanoplastic toxicity',
            authorsShort: 'Yontem and Ahbab',
            journal: 'Cambridge Prisms: Plastics',
            year: 2024,
            url:
                'https://www.cambridge.org/core/journals/cambridge-prisms-plastics/article/mitochondria-as-a-target-of-micro-and-nanoplastic-toxicity/5A3E8C7CDB7F9919874A3F10F7586A78',
            studyType: 'Review',
            summary:
                'Reviews mitochondrial oxidative stress, membrane injury, and bioenergetic dysfunction.',
            tags: ['review', 'mitochondria', 'cell stress'],
          ),
          _study(
            title:
                'Coupling between electrons\' spin and proton transfer in chiral biological crystals',
            authorsShort: 'Goren et al.',
            journal: 'PNAS',
            year: 2025,
            url: 'https://www.pnas.org/doi/10.1073/pnas.2500584122',
            doiOrPubMed: 'doi:10.1073/pnas.2500584122',
            studyType: 'Mechanistic study',
            summary:
                'Provides a mechanistic reference for proton-transfer and charge-coupled bioelectric processes.',
            tags: ['mechanism', 'bioelectric', 'proton transfer'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_vitality',
      title: l10n.detailVitalityTissuesTitle,
      subtitle: l10n.detailVitalityTissuesSubtitle,
      icon: Icons.favorite_outline,
      themeColor: AppColors.neonCrimson,
      glowColor: AppColors.neonCrimsonGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailVitalityTissuesEntry1Highlight,
          description: l10n.detailVitalityTissuesEntry1Desc,
          bulletPoints: [
            l10n.detailVitalityTissuesEntry1Bullet1,
            l10n.detailVitalityTissuesEntry1Bullet2,
            l10n.detailVitalityTissuesEntry1Bullet3,
            l10n.detailVitalityTissuesEntry1Bullet4,
          ],
          pdfStartPage: 116,
          pdfEndPage: 119,
          pdfCategory: 'Vitality & Tissues (Heart, Blood, Organs)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData reproduction(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'reproductive-damage',
        title: l10n.detailReproductionEntry1Highlight,
        description: l10n.detailReproductionEntry1Desc,
        studies: [
          _study(
            title:
                'Prevalence and implications of microplastic contaminants in general human seminal fluid: A Raman spectroscopic study',
            authorsShort: 'Li et al.',
            journal: 'Science of The Total Environment',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0048969724036696?via%3Dihub',
            studyType: 'Human biomonitoring study',
            summary:
                'Reports microplastic contamination in human seminal fluid samples.',
            tags: ['human study', 'fertility', 'male reproduction'],
          ),
          _study(
            title:
                'First evidence of microplastics in human ovarian follicular fluid: An emerging threat to female fertility',
            authorsShort: 'Montano et al.',
            journal: 'Ecotoxicology and Environmental Safety',
            year: 2025,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0147651325002040?via%3Dihub',
            studyType: 'Human biomonitoring study',
            summary:
                'Finds microplastics in ovarian follicular fluid, tying exposure to female fertility concerns.',
            tags: ['human study', 'fertility', 'female reproduction'],
          ),
          _study(
            title:
                'Plasticenta: First evidence of microplastics in human placenta',
            authorsShort: 'Ragusa et al.',
            journal: 'Environment International',
            year: 2021,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0160412020322297?via%3Dihub',
            studyType: 'Human tissue study',
            summary:
                'First widely cited evidence of microplastics present in the human placenta.',
            tags: ['human study', 'placenta', 'pregnancy'],
          ),
          _study(
            title:
                'Prenatal phthalate exposure and adverse birth outcomes in the USA',
            authorsShort: 'Trasande et al.',
            journal: 'The Lancet Planetary Health',
            year: 2024,
            url:
                'https://www.thelancet.com/journals/lanplh/article/PIIS2542-5196(23)00270-X/fulltext',
            studyType: 'Population study',
            summary:
                'Associates prenatal phthalate exposure with substantial adverse birth outcome burden.',
            tags: ['population', 'pregnancy', 'birth outcomes'],
          ),
          _study(
            title:
                'Maternal exposure to polystyrene nanoplastics causes brain abnormalities in progeny',
            authorsShort: 'Jeong et al.',
            journal: 'Journal of Hazardous Materials',
            year: 2022,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0304389421027849?via%3Dihub',
            studyType: 'Animal study',
            summary:
                'Shows developmental brain abnormalities in offspring after maternal nanoplastic exposure.',
            tags: ['animal study', 'development', 'nanoplastic'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_reproduction',
      title: l10n.detailReproductionTitle,
      subtitle: l10n.detailReproductionSubtitle,
      icon: Icons.child_care_outlined,
      themeColor: AppColors.neonViolet,
      glowColor: AppColors.neonVioletGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailReproductionEntry1Highlight,
          description: l10n.detailReproductionEntry1Desc,
          bulletPoints: [
            l10n.detailReproductionEntry1Bullet1,
            l10n.detailReproductionEntry1Bullet2,
            l10n.detailReproductionEntry1Bullet3,
            l10n.detailReproductionEntry1Bullet4,
          ],
          pdfStartPage: 120,
          pdfEndPage: 131,
          pdfCategory:
              'Reproduction & Development (Placenta, Fetus, Fertility)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData entryGates(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'inhalation',
        title: l10n.detailEntryGatesEntry1Highlight,
        description: l10n.detailEntryGatesEntry1Desc,
        studies: [
          _study(
            title:
                'Airborne micro- and nanoplastics: emerging causes of respiratory diseases',
            authorsShort: 'Gou et al.',
            journal: 'Particle and Fibre Toxicology',
            year: 2024,
            url: 'https://link.springer.com/article/10.1186/s12989-024-00613-6',
            studyType: 'Review',
            summary:
                'Summarizes inhalation exposure and respiratory disease mechanisms for airborne particles.',
            tags: ['review', 'inhalation', 'respiratory'],
          ),
          _study(
            title: 'Presence of airborne microplastics in human lung tissue',
            authorsShort: 'Amato-Lourenco et al.',
            journal: 'Journal of Hazardous Materials',
            year: 2021,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0304389421010888?via%3Dihub',
            studyType: 'Human tissue study',
            summary:
                'Detects airborne microplastics in human lung tissue, supporting direct pulmonary exposure.',
            tags: ['human study', 'lungs', 'inhalation'],
          ),
          _study(
            title:
                'Transport and deposition of microplastics and nanoplastics in the human respiratory tract',
            authorsShort: 'Huang et al.',
            journal: 'Environmental Advances',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S2666765724000437?via%3Dihub',
            studyType: 'Transport study',
            summary:
                'Models where particles deposit along the respiratory tract after inhalation.',
            tags: ['modeling', 'respiratory', 'deposition'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'ingestion',
        title: l10n.detailEntryGatesEntry2Highlight,
        description: l10n.detailEntryGatesEntry2Desc,
        studies: [
          _study(
            title:
                'Micro- and nano-plastics in edible fruit and vegetables. The first diet risks assessment for the general population',
            authorsShort: 'Oliveri Conti et al.',
            journal: 'Environmental Research',
            year: 2020,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0013935120305703?via%3Dihub',
            studyType: 'Exposure assessment',
            summary:
                'Provides early dietary risk assessment for edible produce contamination.',
            tags: ['diet', 'food', 'ingestion'],
          ),
          _study(
            title:
                'Estimation of the mass of microplastics ingested - A pivotal first step towards human health risk assessment',
            authorsShort: 'Senathirajah et al.',
            journal: 'Journal of Hazardous Materials',
            year: 2021,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0304389420319944?via%3Dihub',
            studyType: 'Exposure assessment',
            summary:
                'Estimates ingestion mass from food and beverages for risk-assessment framing.',
            tags: ['risk assessment', 'diet', 'ingestion'],
          ),
          _study(
            title:
                'Anthropogenic contamination of tap water, beer, and sea salt',
            authorsShort: 'Kosuth et al.',
            journal: 'PLoS ONE',
            year: 2018,
            url:
                'https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0194970',
            studyType: 'Exposure study',
            summary:
                'Shows contamination across common drinking and food-related sources.',
            tags: ['drinking water', 'food', 'exposure'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'skin',
        title: l10n.detailEntryGatesEntry3Highlight,
        description: l10n.detailEntryGatesEntry3Desc,
        studies: [
          _study(
            title:
                'Potential Health Impact of Microplastics: A Review of Environmental Distribution, Human Exposure, and Toxic Effects',
            authorsShort: 'Li et al.',
            journal: 'Environmental Health',
            year: 2023,
            url: 'https://pubs.acs.org/doi/10.1021/envhealth.3c00052',
            studyType: 'Review',
            summary:
                'Reviews human exposure routes including dermal contact and translocation questions.',
            tags: ['review', 'dermal', 'exposure'],
          ),
          _study(
            title: 'Impact of Microplastics and Nanoplastics on Human Health',
            authorsShort: 'Yee et al.',
            journal: 'Nanomaterials',
            year: 2021,
            url: 'https://www.mdpi.com/2079-4991/11/2/496',
            studyType: 'Review',
            summary:
                'Provides route-specific overview of uptake pathways and health effects, including skin contact considerations.',
            tags: ['review', 'dermal', 'uptake'],
          ),
          _study(
            title:
                'The potential impact of nano- and microplastics on human health: Understanding human health risks',
            authorsShort: 'Winiarska et al.',
            journal: 'Environmental Research',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0013935124004390?via%3Dihub',
            studyType: 'Review',
            summary:
                'Updates route-of-exposure evidence and uncertainty across inhalation, ingestion, and skin contact.',
            tags: ['review', 'risk', 'dermal'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_entry',
      title: l10n.detailEntryGatesTitle,
      subtitle: l10n.detailEntryGatesSubtitle,
      icon: Icons.air_outlined,
      themeColor: AppColors.neonOrange,
      glowColor: AppColors.neonOrangeGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailEntryGatesEntry1Highlight,
          description: l10n.detailEntryGatesEntry1Desc,
          pdfStartPage: 70,
          pdfEndPage: 91,
          pdfCategory: 'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
        ),
        DetailEntry(
          highlight: l10n.detailEntryGatesEntry2Highlight,
          description: l10n.detailEntryGatesEntry2Desc,
          pdfStartPage: 70,
          pdfEndPage: 91,
          pdfCategory: 'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
        ),
        DetailEntry(
          highlight: l10n.detailEntryGatesEntry3Highlight,
          description: l10n.detailEntryGatesEntry3Desc,
          pdfStartPage: 70,
          pdfEndPage: 91,
          pdfCategory: 'Entry Gates (Inhalation, Ingestion, Skin Penetration)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData physicalAttack(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'electrostatic-charge',
        title: l10n.detailPhysicalAttackEntry1Highlight,
        description: l10n.detailPhysicalAttackEntry1Desc,
        studies: [
          _study(
            title:
                'Selective Targeting of Neurons with Inorganic Nanoparticles: Revealing the Crucial Role of Nanoparticle Surface Charge',
            authorsShort: 'Dante et al.',
            journal: 'ACS Nano',
            year: 2017,
            url: 'https://pubs.acs.org/doi/10.1021/acsnano.7b00397',
            studyType: 'Mechanistic study',
            summary:
                'Demonstrates how charged nanoparticles preferentially interact with electrically active neurons.',
            tags: ['surface charge', 'neurons', 'mechanism'],
          ),
          _study(
            title:
                'Exposure to polystyrene nanoparticles leads to changes in the zeta potential of bacterial cells',
            authorsShort: 'Zajac et al.',
            journal: 'Scientific Reports',
            year: 2023,
            url: 'https://www.nature.com/articles/s41598-023-36603-5',
            studyType: 'Cell study',
            summary:
                'Shows measurable electrical surface-potential shifts after nanoparticle exposure.',
            tags: ['surface charge', 'zeta potential', 'cell study'],
          ),
          _study(
            title:
                'Interplay Between Nanoplastics and the Immune System of the Mediterranean Sea Urchin Paracentrotus lividus',
            authorsShort: 'Murano et al.',
            journal: 'Frontiers in Marine Science',
            year: 2021,
            url:
                'https://www.frontiersin.org/journals/marine-science/articles/10.3389/fmars.2021.647394/full',
            studyType: 'Mechanistic study',
            summary:
                'Shows how positively charged nanoplastics can trigger membrane damage and immune disruption.',
            tags: ['surface charge', 'membrane damage', 'immune'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'electrical-interference',
        title: l10n.detailPhysicalAttackEntry2Highlight,
        description: l10n.detailPhysicalAttackEntry2Desc,
        studies: [
          _study(
            title:
                'Surface-Functionalized Polystyrene Nanoparticles Alter the Transmembrane Potential via Ion-Selective Pores Maintaining Global Bilayer Integrity',
            authorsShort: 'Perini et al.',
            journal: 'Langmuir',
            year: 2022,
            url: 'https://pubs.acs.org/doi/10.1021/acs.langmuir.2c02487',
            studyType: 'Mechanistic study',
            summary:
                'Shows nanoparticle-driven changes in transmembrane potential without full membrane rupture.',
            tags: ['bioelectric', 'membrane potential', 'mechanism'],
          ),
          _study(
            title:
                'Coupling between electrons\' spin and proton transfer in chiral biological crystals',
            authorsShort: 'Goren et al.',
            journal: 'PNAS',
            year: 2025,
            url: 'https://www.pnas.org/doi/10.1073/pnas.2500584122',
            studyType: 'Mechanistic study',
            summary:
                'Provides a reference point for charge-sensitive proton-transfer processes in living systems.',
            tags: ['bioelectric', 'proton transfer', 'mechanism'],
          ),
          _study(
            title:
                'Microplastics in the bloodstream can induce cerebral thrombosis by causing cell obstruction and lead to neurobehavioral abnormalities',
            authorsShort: 'Huang et al.',
            journal: 'Science Advances',
            year: 2025,
            url: 'https://www.science.org/doi/10.1126/sciadv.adr8243',
            studyType: 'In vivo study',
            summary:
                'Connects bloodstream obstruction to downstream neurologic and behavioral disruption.',
            tags: ['circulation', 'neuro', 'bioelectric'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'structural-deformation',
        title: l10n.detailPhysicalAttackEntry3Highlight,
        description: l10n.detailPhysicalAttackEntry3Desc,
        studies: [
          _study(
            title:
                'Micro- and Nanoplastics\' Effects on Protein Folding and Amyloidosis',
            authorsShort: 'Windheim et al.',
            journal: 'International Journal of Molecular Sciences',
            year: 2022,
            url: 'https://www.mdpi.com/1422-0067/23/18/10329',
            studyType: 'Review',
            summary:
                'Reviews how plastic particles perturb protein folding and aggregation pathways.',
            tags: ['protein folding', 'structural', 'review'],
          ),
          _study(
            title:
                'Interfacial Interactions between Nanoplastics and Biological Systems: toward an Atomic and Molecular Understanding of Plastics-Driven Biological Dyshomeostasis',
            authorsShort: 'Karim et al.',
            journal: 'ACS Applied Materials and Interfaces',
            year: 2024,
            url: 'https://pubs.acs.org/doi/10.1021/acsami.4c03008',
            studyType: 'Mechanistic review',
            summary:
                'Frames structural dyshomeostasis through surface-binding, membrane, and protein interactions.',
            tags: ['structural', 'surface chemistry', 'review'],
          ),
          _study(
            title:
                'Recent insights into uptake, toxicity, and molecular targets of microplastics and nanoplastics relevant to human health impacts',
            authorsShort: 'Khan and Jia',
            journal: 'iScience',
            year: 2023,
            url:
                'https://www.sciencedirect.com/science/article/pii/S2589004223001384',
            studyType: 'Review',
            summary:
                'Synthesizes molecular damage pathways, including oxidative stress and structural biomolecule disruption.',
            tags: ['review', 'molecular targets', 'toxicity'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'human_ways_of_destruction',
      title: l10n.detailPhysicalAttackTitle,
      subtitle: l10n.detailPhysicalAttackSubtitle,
      icon: Icons.science_outlined,
      themeColor: AppColors.neonWhite,
      glowColor: AppColors.neonWhiteGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailPhysicalAttackEntry1Highlight,
          description: l10n.detailPhysicalAttackEntry1Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
        ),
        DetailEntry(
          highlight: l10n.detailPhysicalAttackEntry2Highlight,
          description: l10n.detailPhysicalAttackEntry2Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
        ),
        DetailEntry(
          highlight: l10n.detailPhysicalAttackEntry3Highlight,
          description: l10n.detailPhysicalAttackEntry3Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Attack (Quantum, Molecular, Cellular Damage)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData worldOcean(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'hydrogen-bond-disruption',
        title: l10n.detailWorldOceanEntry1Highlight,
        description: l10n.detailWorldOceanEntry1Desc,
        studies: [
          _study(
            title: 'Another Year of Record Heat for the Oceans',
            authorsShort: 'Cheng et al.',
            journal: 'Advances in Atmospheric Sciences',
            year: 2023,
            url: 'https://link.springer.com/article/10.1007/s00376-023-2385-2',
            studyType: 'Climate observation',
            summary:
                'Updates the record-setting ocean heat signal across the global ocean.',
            tags: ['ocean heat', 'climate', 'observation'],
          ),
          _study(
            title:
                'Frequent marine heatwaves hidden below the surface of the global ocean',
            authorsShort: 'Sun et al.',
            journal: 'Nature Geoscience',
            year: 2023,
            url: 'https://www.nature.com/articles/s41561-023-01325-w',
            studyType: 'Observation study',
            summary:
                'Shows major heat anomalies below the surface, relevant to stratified ocean impacts.',
            tags: ['marine heatwave', 'subsurface', 'ocean'],
          ),
          _study(
            title:
                'Microplastics contaminate the deepest part of the world\'s ocean',
            authorsShort: 'Peng et al.',
            journal: 'Geochemical Perspectives Letters',
            year: 2018,
            url: 'https://www.geochemicalperspectivesletters.org/article1829/',
            studyType: 'Field study',
            summary:
                'Finds plastic contamination at Mariana Trench depths with polymer-specific distribution patterns.',
            tags: ['deep ocean', 'field study', 'contamination'],
          ),
          _study(
            title:
                'Abundance, size and polymer composition of marine microplastics and their modelled vertical distribution',
            authorsShort: 'Enders et al.',
            journal: 'Marine Pollution Bulletin',
            year: 2015,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0025326X15300370?via%3Dihub',
            studyType: 'Distribution study',
            summary:
                'Models how polymer type and particle properties shape vertical ocean distribution.',
            tags: ['vertical distribution', 'ocean', 'modeling'],
          ),
          _study(
            title:
                'Seven years into the North Pacific garbage patch: legacy plastic fragments rising disproportionately faster than larger floating objects',
            authorsShort: 'Lebreton et al.',
            journal: 'Environmental Research Letters',
            year: 2024,
            url: 'https://iopscience.iop.org/article/10.1088/1748-9326/ad78ed',
            studyType: 'Field study',
            summary:
                'Shows accelerating fragmentation and growth of small plastic particles in the Pacific.',
            tags: ['fragmentation', 'Pacific', 'field study'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_ocean',
      title: l10n.detailWorldOceanTitle,
      subtitle: l10n.detailWorldOceanSubtitle,
      icon: Icons.waves_outlined,
      themeColor: AppColors.neonOcean,
      glowColor: AppColors.neonOceanGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailWorldOceanEntry1Highlight,
          description: l10n.detailWorldOceanEntry1Desc,
          bulletPoints: [
            l10n.detailWorldOceanEntry1Bullet1,
            l10n.detailWorldOceanEntry1Bullet2,
          ],
          pdfStartPage: 45,
          pdfEndPage: 66,
          pdfCategory: 'World Ocean (Marine Contamination, Ocean Impacts)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData atmosphere(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'low-heavy-clouds',
        title: l10n.detailAtmosphereEntry1Highlight,
        description: l10n.detailAtmosphereEntry1Desc,
        studies: [
          _study(
            title:
                'Airborne hydrophilic microplastics in cloud water at high altitudes and their role in cloud formation',
            authorsShort: 'Wang et al.',
            journal: 'Environmental Chemistry Letters',
            year: 2023,
            url: 'https://link.springer.com/article/10.1007/s10311-023-01626-x',
            studyType: 'Field study',
            summary:
                'Detects hydrophilic plastics in cloud water and links them to cloud-formation processes.',
            tags: ['atmosphere', 'clouds', 'field study'],
          ),
          _study(
            title:
                'Pristine and Aged Microplastics Can Nucleate Ice through Immersion Freezing',
            authorsShort: 'Busse et al.',
            journal: 'ACS EST Air',
            year: 2024,
            url: 'https://doi.org/10.1021/acsestair.4c00146',
            studyType: 'Laboratory study',
            summary:
                'Shows microplastics acting as ice-nucleating particles during cloud freezing.',
            tags: ['ice nucleation', 'clouds', 'laboratory'],
          ),
          _study(
            title: 'Plastic rain in protected areas of the United States',
            authorsShort: 'Brahney et al.',
            journal: 'Science',
            year: 2020,
            url: 'https://www.science.org/doi/10.1126/science.aaz5819',
            studyType: 'Field study',
            summary:
                'Documents atmospheric deposition of plastic particles over protected landscapes.',
            tags: ['atmosphere', 'deposition', 'field study'],
          ),
          _study(
            title: 'Atmospheric electricity and cloud microphysics',
            authorsShort: 'Harrison',
            journal: 'CERN Proceedings',
            year: 2002,
            url: 'https://cds.cern.ch/record/557170/files/p75.pdf',
            studyType: 'Conceptual reference',
            summary:
                'Provides background on cloud charge separation and atmospheric electricity relevant to particle interactions.',
            tags: ['atmosphere', 'electricity', 'reference'],
          ),
          _study(
            title:
                'Projected increase in lightning strikes in the United States due to global warming',
            authorsShort: 'Romps et al.',
            journal: 'Science',
            year: 2014,
            url: 'https://www.science.org/doi/10.1126/science.1259100',
            studyType: 'Projection study',
            summary:
                'Models how atmospheric changes intensify lightning activity under warming conditions.',
            tags: ['lightning', 'climate', 'projection'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_atmosphere',
      title: l10n.detailAtmosphereTitle,
      subtitle: l10n.detailAtmosphereSubtitle,
      icon: Icons.cloud_outlined,
      themeColor: AppColors.neonAtmos,
      glowColor: AppColors.neonAtmosGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailAtmosphereEntry1Highlight,
          description: l10n.detailAtmosphereEntry1Desc,
          pdfStartPage: 23,
          pdfEndPage: 30,
          pdfCategory:
              'Atmosphere & Global Water Cycle (Airborne Plastics, Precipitation)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData florFauna(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'bioelectric-signals',
        title: l10n.detailFloraFaunaEntry1Highlight,
        description: l10n.detailFloraFaunaEntry1Desc,
        studies: [
          _study(
            title:
                'Microplastics reach the brain and interfere with honey bee cognition',
            authorsShort: 'Pasquini et al.',
            journal: 'Science of The Total Environment',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S0048969723079925',
            studyType: 'Animal study',
            summary:
                'Links plastic exposure with cognition effects in pollinators.',
            tags: ['pollinators', 'animal study', 'ecosystems'],
          ),
          _study(
            title:
                'Plastic pollution in agricultural landscapes: an overlooked threat to pollination, biocontrol and food security',
            authorsShort: 'Sheng et al.',
            journal: 'Nature Communications',
            year: 2024,
            url: 'https://www.nature.com/articles/s41467-024-52734-3',
            studyType: 'Review',
            summary:
                'Frames plastics as a systems-level threat to pollination and agricultural resilience.',
            tags: ['pollination', 'ecosystem', 'review'],
          ),
          _study(
            title:
                'Microplastics incorporated by honeybees from food are transferred to honey, wax and larvae',
            authorsShort: 'Alma et al.',
            journal: 'Environmental Pollution',
            year: 2023,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0269749123000805?via%3Dihub',
            studyType: 'Transfer study',
            summary:
                'Shows particle transfer through bee products and brood pathways.',
            tags: ['pollinators', 'transfer', 'food web'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'photosynthesis-damage',
        title: l10n.detailFloraFaunaEntry2Highlight,
        description: l10n.detailFloraFaunaEntry2Desc,
        studies: [
          _study(
            title:
                'A global estimate of multiecosystem photosynthesis losses under microplastic pollution',
            authorsShort: 'Zhu et al.',
            journal: 'PNAS',
            year: 2025,
            url: 'https://www.pnas.org/doi/10.1073/pnas.2423957122',
            studyType: 'Global modeling study',
            summary:
                'Estimates global photosynthesis losses across terrestrial, freshwater, and marine systems.',
            tags: ['photosynthesis', 'global model', 'ecosystems'],
          ),
          _study(
            title:
                'Uptake and physiological impacts of nanoplastics in trees with divergent water use strategies',
            authorsShort: 'Murazzi et al.',
            journal: 'Environmental Science: Nano',
            year: 2024,
            url:
                'https://pubs.rsc.org/en/content/articlelanding/2024/en/d4en00286e',
            studyType: 'Plant study',
            summary:
                'Shows uptake and physiological stress in tree systems after nanoplastic exposure.',
            tags: ['plants', 'tree physiology', 'nanoplastic'],
          ),
          _study(
            title:
                'Nanoplastic exposure inhibits growth, photosynthetic pigment synthesis and oxidative enzymes in microalgae',
            authorsShort: 'Sarkar et al.',
            journal: 'Journal of Hazardous Materials Advances',
            year: 2025,
            url:
                'https://www.sciencedirect.com/science/article/pii/S2772416625000257',
            studyType: 'Laboratory study',
            summary:
                'Shows impaired pigment synthesis and oxidative enzyme balance in primary producers.',
            tags: ['microalgae', 'photosynthesis', 'laboratory'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_bio',
      title: l10n.detailFloraFaunaTitle,
      subtitle: l10n.detailFloraFaunaSubtitle,
      icon: Icons.nature_outlined,
      themeColor: AppColors.neonBio,
      glowColor: AppColors.neonBioGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailFloraFaunaEntry1Highlight,
          description: l10n.detailFloraFaunaEntry1Desc,
          bulletPoints: [
            l10n.detailFloraFaunaEntry1Bullet1,
            l10n.detailFloraFaunaEntry1Bullet2,
          ],
          pdfStartPage: 31,
          pdfEndPage: 44,
          pdfCategory:
              'Flora, Fauna & Soil Biota (Terrestrial Ecosystems, Photosynthesis)',
        ),
        DetailEntry(
          highlight: l10n.detailFloraFaunaEntry2Highlight,
          description: l10n.detailFloraFaunaEntry2Desc,
          pdfStartPage: 31,
          pdfEndPage: 44,
          pdfCategory:
              'Flora, Fauna & Soil Biota (Terrestrial Ecosystems, Photosynthesis)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData magneticField(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'magnetic-destabilization',
        title: l10n.detailMagneticFieldEntry1Highlight,
        description: l10n.detailMagneticFieldEntry1Desc,
        studies: [
          _study(
            title:
                'Polar Drift in the 1990s Explained by Terrestrial Water Storage Changes',
            authorsShort: 'Deng et al.',
            journal: 'Geophysical Research Letters',
            year: 2021,
            url:
                'https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2020GL092114',
            studyType: 'Geophysics study',
            summary:
                'Shows large-scale Earth-system mass redistribution can shift polar motion.',
            tags: ['geophysics', 'polar drift', 'mass redistribution'],
          ),
          _study(
            title:
                'Detection of a large-scale mass redistribution in the terrestrial system since 1998',
            authorsShort: 'Cox and Chao',
            journal: 'Science',
            year: 2002,
            url: 'https://www.science.org/doi/10.1126/science.1072188',
            studyType: 'Geophysics study',
            summary:
                'Measures abrupt terrestrial mass redistribution relevant to Earth-shape dynamics.',
            tags: ['mass redistribution', 'geophysics'],
          ),
          _study(
            title: 'An accelerating high-latitude jet in Earth\'s core',
            authorsShort: 'Livermore et al.',
            journal: 'Nature Geoscience',
            year: 2017,
            url: 'https://www.nature.com/articles/ngeo2859',
            studyType: 'Core dynamics study',
            summary:
                'Uses geomagnetic observations to show dynamic changes within the liquid outer core.',
            tags: ['earth core', 'geomagnetism', 'core dynamics'],
          ),
          _study(
            title:
                'International Geomagnetic Reference Field: the thirteenth generation',
            authorsShort: 'Alken et al.',
            journal: 'Earth, Planets and Space',
            year: 2021,
            url: 'https://link.springer.com/article/10.1186/s40623-020-01288-x',
            studyType: 'Reference model',
            summary:
                'Documents current geomagnetic reference-field changes and secular variation.',
            tags: ['geomagnetism', 'reference', 'field intensity'],
          ),
          _study(
            title:
                'Remnant of the late Permian superplume that generated the Siberian Traps inferred from geomagnetic data',
            authorsShort: 'Li et al.',
            journal: 'Nature Communications',
            year: 2023,
            url: 'https://www.nature.com/articles/s41467-023-37053-3',
            studyType: 'Geodynamic study',
            summary:
                'Uses geomagnetic data to infer deep mantle structure beneath Siberia.',
            tags: ['mantle', 'geomagnetic', 'geodynamics'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_magnetic',
      title: l10n.detailMagneticFieldTitle,
      subtitle: l10n.detailMagneticFieldSubtitle,
      icon: Icons.explore_outlined,
      themeColor: AppColors.neonMagma,
      glowColor: AppColors.neonMagmaGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailMagneticFieldEntry1Highlight,
          description: l10n.detailMagneticFieldEntry1Desc,
          pdfStartPage: 68,
          pdfEndPage: 69,
          pdfCategory: 'Magnetic Field & Earth\'s Core (Geophysical Impacts)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData planetEntryGates(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'plastic-system-failure',
        title: l10n.detailPlanetEntryGatesEntry1Highlight,
        description: l10n.detailPlanetEntryGatesEntry1Desc,
        studies: [
          _study(
            title: 'Production, use, and fate of all plastics ever made',
            authorsShort: 'Geyer et al.',
            journal: 'Science Advances',
            year: 2017,
            url: 'https://www.science.org/doi/10.1126/sciadv.1700782',
            studyType: 'Global accounting study',
            summary:
                'Maps the cumulative fate of plastic production into recycling, incineration, landfill, and waste.',
            tags: ['plastic waste', 'global accounting', 'systems'],
          ),
          _study(
            title: 'Plastic waste inputs from land into the ocean',
            authorsShort: 'Jambeck et al.',
            journal: 'Science',
            year: 2015,
            url: 'https://www.science.org/doi/10.1126/science.1260352',
            studyType: 'Global model',
            summary:
                'Quantifies land-based inputs of plastic waste into ocean systems.',
            tags: ['ocean entry', 'plastic waste', 'modeling'],
          ),
          _study(
            title: 'Export of Plastic Debris by Rivers into the Sea',
            authorsShort: 'Schmidt et al.',
            journal: 'Environmental Science and Technology',
            year: 2017,
            url: 'https://pubs.acs.org/doi/10.1021/acs.est.7b02368',
            studyType: 'Transport model',
            summary:
                'Shows the river systems responsible for a large share of marine plastic transport.',
            tags: ['rivers', 'transport', 'ocean entry'],
          ),
          _study(
            title: 'Plastic debris in lakes and reservoirs',
            authorsShort: 'Nava et al.',
            journal: 'Nature',
            year: 2023,
            url: 'https://www.nature.com/articles/s41586-023-06168-4',
            studyType: 'Field study',
            summary:
                'Documents severe contamination in lakes and reservoirs as regional entry systems.',
            tags: ['lakes', 'reservoirs', 'field study'],
          ),
          _study(
            title:
                'Accumulation and fragmentation of plastic debris in global environments',
            authorsShort: 'Barnes et al.',
            journal: 'Philosophical Transactions of the Royal Society B',
            year: 2009,
            url:
                'https://royalsocietypublishing.org/rstb/article-abstract/364/1526/1985/21064/Accumulation-and-fragmentation-of-plastic-debris?redirectedFrom=fulltext',
            studyType: 'Review',
            summary:
                'Classic review on fragmentation pathways that create persistent smaller plastic particles.',
            tags: ['fragmentation', 'review', 'environment'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_entry',
      title: l10n.detailPlanetEntryGatesTitle,
      subtitle: l10n.detailPlanetEntryGatesSubtitle,
      icon: Icons.delete_outline,
      themeColor: AppColors.neonSource,
      glowColor: AppColors.neonSourceGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailPlanetEntryGatesEntry1Highlight,
          description: l10n.detailPlanetEntryGatesEntry1Desc,
          pdfStartPage: 7,
          pdfEndPage: 22,
          pdfCategory:
              'Entry Gates - Crisis Sources (Plastic Production, Waste Management)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }

  static CategoryDetailData physicalProperties(AppLocalizations l10n) {
    final evidenceSections = [
      EvidenceSection(
        id: 'water-hydrogen-bonds',
        title: l10n.detailPhysicalPropertiesEntry1Highlight,
        description: l10n.detailPhysicalPropertiesEntry1Desc,
        studies: [
          _study(
            title:
                'A hierarchical clustering method of hydrogen bond networks in liquid water undergoing shear flow',
            authorsShort: 'Gao et al.',
            journal: 'Scientific Reports',
            year: 2021,
            url: 'https://www.nature.com/articles/s41598-021-88810-7',
            studyType: 'Water structure study',
            summary:
                'Characterizes hydrogen-bond network structure in liquid water under dynamic conditions.',
            tags: ['water', 'hydrogen bonds', 'structure'],
          ),
          _study(
            title:
                'Water clusters and density fluctuations in liquid water based on extended hierarchical clustering methods',
            authorsShort: 'Gao et al.',
            journal: 'Scientific Reports',
            year: 2022,
            url: 'https://www.nature.com/articles/s41598-022-11947-6',
            studyType: 'Water structure study',
            summary:
                'Studies cluster formation and density fluctuations in liquid water.',
            tags: ['water', 'clusters', 'structure'],
          ),
          _study(
            title:
                'Electrolytes induce long-range orientational order and free energy changes in the H-bond network of bulk water',
            authorsShort: 'Chen et al.',
            journal: 'Science Advances',
            year: 2016,
            url: 'https://www.science.org/doi/10.1126/sciadv.1501891',
            studyType: 'Water physics study',
            summary:
                'Shows how charged species alter bulk-water orientational order and hydration structure.',
            tags: ['water', 'charge', 'hydration shell'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'heavy-clouds',
        title: l10n.detailPhysicalPropertiesEntry2Highlight,
        description: l10n.detailPhysicalPropertiesEntry2Desc,
        studies: [
          _study(
            title:
                'Airborne hydrophilic microplastics in cloud water at high altitudes and their role in cloud formation',
            authorsShort: 'Wang et al.',
            journal: 'Environmental Chemistry Letters',
            year: 2023,
            url: 'https://link.springer.com/article/10.1007/s10311-023-01626-x',
            studyType: 'Field study',
            summary:
                'Connects airborne plastics with cloud-water chemistry and formation.',
            tags: ['clouds', 'atmosphere', 'microplastics'],
          ),
          _study(
            title:
                'Pristine and Aged Microplastics Can Nucleate Ice through Immersion Freezing',
            authorsShort: 'Busse et al.',
            journal: 'ACS EST Air',
            year: 2024,
            url: 'https://doi.org/10.1021/acsestair.4c00146',
            studyType: 'Laboratory study',
            summary:
                'Demonstrates direct ice-nucleation capacity of microplastics.',
            tags: ['ice nucleation', 'clouds', 'laboratory'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'bioelectric-signals',
        title: l10n.detailPhysicalPropertiesEntry3Highlight,
        description: l10n.detailPhysicalPropertiesEntry3Desc,
        studies: [
          _study(
            title:
                'A review of microplastic surface interactions in water and potential capturing methods',
            authorsShort: 'Rahman et al.',
            journal: 'Water Science and Engineering',
            year: 2024,
            url:
                'https://www.sciencedirect.com/science/article/pii/S1674237023001217?via%3Dihub',
            studyType: 'Review',
            summary:
                'Reviews charge acquisition and surface interaction behavior of plastics in water.',
            tags: ['review', 'surface interactions', 'charge'],
          ),
          _study(
            title:
                'Surface-Functionalized Polystyrene Nanoparticles Alter the Transmembrane Potential via Ion-Selective Pores Maintaining Global Bilayer Integrity',
            authorsShort: 'Perini et al.',
            journal: 'Langmuir',
            year: 2022,
            url: 'https://pubs.acs.org/doi/10.1021/acs.langmuir.2c02487',
            studyType: 'Mechanistic study',
            summary:
                'Provides a direct membrane-potential reference for bioelectric interference.',
            tags: ['bioelectric', 'membrane potential', 'mechanism'],
          ),
        ],
      ),
      EvidenceSection(
        id: 'photosynthesis',
        title: l10n.detailPhysicalPropertiesEntry4Highlight,
        description: l10n.detailPhysicalPropertiesEntry4Desc,
        studies: [
          _study(
            title:
                'Effect of microplastics exposure on the photosynthesis system of freshwater algae',
            authorsShort: 'Wu et al.',
            journal: 'Journal of Hazardous Materials',
            year: 2019,
            url:
                'https://www.sciencedirect.com/science/article/abs/pii/S0304389419304674?via%3Dihub',
            studyType: 'Laboratory study',
            summary:
                'Shows direct damage to the photosynthesis system in freshwater algae under microplastic exposure.',
            tags: ['photosynthesis', 'algae', 'laboratory'],
          ),
        ],
      ),
    ];

    return CategoryDetailData(
      categoryKey: 'planet_physical',
      title: l10n.detailPhysicalPropertiesTitle,
      subtitle: l10n.detailPhysicalPropertiesSubtitle,
      icon: Icons.hub_outlined,
      themeColor: AppColors.neonPhysics,
      glowColor: AppColors.neonPhysicsGlow,
      entries: [
        DetailEntry(
          highlight: l10n.detailPhysicalPropertiesEntry1Highlight,
          description: l10n.detailPhysicalPropertiesEntry1Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Properties (Polymer Degradation, Persistence)',
        ),
        DetailEntry(
          highlight: l10n.detailPhysicalPropertiesEntry2Highlight,
          description: l10n.detailPhysicalPropertiesEntry2Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Properties (Polymer Degradation, Persistence)',
        ),
        DetailEntry(
          highlight: l10n.detailPhysicalPropertiesEntry3Highlight,
          description: l10n.detailPhysicalPropertiesEntry3Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Properties (Polymer Degradation, Persistence)',
        ),
        DetailEntry(
          highlight: l10n.detailPhysicalPropertiesEntry4Highlight,
          description: l10n.detailPhysicalPropertiesEntry4Desc,
          pdfStartPage: 92,
          pdfEndPage: 119,
          pdfCategory: 'Physical Properties (Polymer Degradation, Persistence)',
        ),
      ],
      evidenceSections: evidenceSections,
      sourceLinks: _toSourceLinks(evidenceSections),
    );
  }
}
