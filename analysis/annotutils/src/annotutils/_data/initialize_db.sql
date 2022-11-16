create table document(
  id integer primary key,
  utf8_text_md5_checksum blob unique not null,
  text text not null,
  pmcid integer,
  pmid integer,
  publication_year integer,
  journal text,
  title text
);

create table label(
  id integer primary key,
  name text unique not null,
  color text
);

create table annotator(
  id integer primary key,
  name text unique not null
);

create table annotation(
  id integer primary key,
  doc_id not null references document(id) on delete cascade,
  label_id not null references label(id) on delete cascade,
  annotator_id not null references annotator(id) on delete cascade,
  start_char integer not null,
  end_char integer not null,
  extra_data text,
  project text not null
);

create table db_info(
  key text unique not null,
  value
);

create view detailed_annotation as
  with annot as
  (select *,
          max(0, start_char - 40) as context_start_char,
          min(length(document.text), end_char + 40) as context_end_char
     from annotation inner join document on annotation.doc_id = document.id)
  select
    pmcid, pmid, publication_year, journal, title,
    label.name as label_name,
    label.color as label_color,
    annotator.name as annotator_name,
    start_char, end_char, extra_data, project,
    substr(
      text, start_char + 1, end_char - start_char) as selected_text,
    end_char - start_char as selected_text_length,
    substr(
      text,
      context_start_char + 1,
      context_end_char - context_start_char
    ) as context,
    context_start_char, context_end_char,
    doc_id, label_id, annotator_id
    from annot
         inner join label on annot.label_id = label.id
         inner join annotator on annot.annotator_id = annotator.id
   order by doc_id, start_char, end_char,
            label_id, annotator_id, annot.id;
