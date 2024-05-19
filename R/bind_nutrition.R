#' Bind document-term nutritions to a tidy, tokenized data set
#'
#' Calculate and bind document-term nutritions to a tidy, tokenized data set.
#'
#' A term's nutrition within a document is computed as:
#'
#' \deqn{nutrition(x) = (1 - c) + c * tf(x) / tf(m),}
#'
#' where \eqn{tf(x)} is the term frequency of `x`, \eqn{tf(m)} is the term frequency of the term
#' with the highest term frequency in the document, and `c` is a sensitivity parameter between zero
#' and one. Clearly, the maximum nutrition value for term `x` in a single document is one, and
#' occurs when \eqn{tf(x) = tf(m)}. As such, noise words (context-free or context-specific) can be
#' identified by their high nutrition values.
#'
#' Note: Aggregation and scaling of term nutritions is left to the user. This typicall involves
#' summing the nutrition scores of a word over all documents and scaling by the number of documents
#' in the corpus. See example.
#'
#' @param tbl A tidy, tokenized data frame object with a column identifying documents and a column
#' of the tokenized terms.
#' @param document The name of the column containing the document identifiers.
#' @param term The name of the column containing the terms.
#' @param c A sensitivity parameter between 0 and 1. Default value is 0.5. Smaller values provide
#' greater sensitivity.
#'
#' @returns Returns the original data frame supplied by the user with an additional column,
#' `nutrition`, containing the term nutritions.
#'
#' @references
#' Churchill, R., Singh, L., Kirov, C. (2018). A Temporal Topic Model for Noisy Mediums. In:
#' Phung, D., Tseng, V., Webb, G., Ho, B., Ganji, M., Rashidi, L. (eds) Advances in Knowledge
#' Discovery and Data Mining. PAKDD 2018.
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' library(tidytext)
#' library(janeaustenr)
#'
#' book_words <- austen_books() %>%
#'   unnest_tokens(output=word, input=text)
#'
#' book_words_nutrition <- book_words %>%
#'   bind_nutrition(document=book, term=word, c=0.25)
#'
#' # To obtain the overall nutrition for a term, we sum all the nutrition values for each word and
#' # divide by the number of documents in the corpus.
#'
#' n_docs <- book_words_nutrition %>%
#'   distinct(book) %>%
#'   nrow()
#'
#' vocabulary_nutrition <- book_words_nutrition %>%
#'   group_by(word) %>%
#'   summarise(
#'     nutrition = sum(nutrition) / n_docs
#'   )
#' }

bind_nutrition <- function(tbl, document, term, c=0.5) {
  if (!(c > 0 & c < 1)) {
    cli::cli_abort("{.arg c} should be between 0 and 1.")
  }

  tbl <- dplyr::group_by(tbl, {{ document }}, {{ term }})
  tbl <- dplyr::count(tbl, name = "tf")
  tbl <- dplyr::ungroup(tbl, {{ term }})
  tbl <- dplyr::mutate(tbl, max_tf = max(tf))
  tbl <- dplyr::ungroup(tbl)

  dplyr::mutate(
    tbl,
    nutrition = (1 - c) + c * tf / max_tf,
    .keep = "unused"
  )
}
