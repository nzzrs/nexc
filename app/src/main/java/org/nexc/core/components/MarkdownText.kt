/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2025-2026. The Nexc Contributors
 *
 * Nexc is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

package org.nexc.core.components

import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.ExperimentalMaterial3ExpressiveApi
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.TextLayoutResult
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import org.nexc.core.enums.userPreferences.ThemeMode
import org.nexc.core.components.dialogs.UrlActionDialog
import org.nexc.core.theme.NexcTheme

/**
 * Displays a Markdown string as formatted text with clickable URL support.
 *
 * The provided Markdown is converted into an [AnnotatedString] using [parseMarkdownToAnnotatedString]
 * and rendered with a [Text] Composable. Taps on URLs trigger the [UrlActionDialog].
 *
 * @param text A Markdown-formatted string to be displayed.
 */
@Composable
fun MarkdownText(
    text: String
) {
    val annotatedString = parseMarkdownToAnnotatedString(text)

    var textLayoutResult by remember { mutableStateOf<TextLayoutResult?>(null) }

    val url = remember { mutableStateOf<String?>(null) }

    url.value?.let {
        UrlActionDialog(it) { url.value = null }
    }

    Text(
        text = annotatedString,
        modifier = Modifier
            .fillMaxWidth()
            .pointerInput(Unit) {
                detectTapGestures { tapOffsetPosition ->
                    val layoutResult = textLayoutResult ?: return@detectTapGestures
                    val position = layoutResult.getOffsetForPosition(tapOffsetPosition)
                    annotatedString
                        .getStringAnnotations(start = position, end = position)
                        .firstOrNull { it.tag == "URL" }
                        ?.let { annotation -> url.value = annotation.item }
                }
            },
        onTextLayout = { result ->
            textLayoutResult = result
        }
    )
}

@OptIn(ExperimentalMaterial3ExpressiveApi::class)
@Composable
fun parseMarkdownToAnnotatedString(markdown: String): AnnotatedString {
    // Define regex patterns
    val linkRegex = """\[(.*?)]\((.*?)\)""".toRegex()
    val boldRegex = """\*\*(.*?)\*\*""".toRegex()
    val italicRegex = """\*(.*?)\*""".toRegex()
    val headingRegex = """^(#{1,3})\s*(.*)""".toRegex(RegexOption.MULTILINE)
    val listRegex = """^- (.*)""".toRegex(RegexOption.MULTILINE)

    val tokens = mutableListOf<MarkdownToken>()
    fun addMatches(pattern: Regex, type: TokenType, groupCount: Int) {
        pattern.findAll(markdown).forEach { result ->
            val matchedGroups = (1..groupCount).map { i -> result.groups[i]?.value ?: "" }
            tokens += MarkdownToken(
                type = type,
                start = result.range.first,
                end = result.range.last + 1,
                groups = matchedGroups
            )
        }
    }

    // Collect tokens for each pattern
    addMatches(linkRegex, TokenType.LINK, 2)
    addMatches(boldRegex, TokenType.BOLD, 1)
    addMatches(italicRegex, TokenType.ITALIC, 1)
    addMatches(headingRegex, TokenType.HEADING, 2)
    addMatches(listRegex, TokenType.LIST, 1)

    tokens.sortBy { it.start }

    val builder = AnnotatedString.Builder()
    var currentIndex = 0

    fun appendGapText(upTo: Int) {
        if (currentIndex < upTo) {
            builder.append(markdown.substring(currentIndex, upTo))
            currentIndex = upTo
        }
    }

    val body = MaterialTheme.typography.bodyLarge.toSpanStyle()

    for (token in tokens) {
        if (token.start < currentIndex) continue
        appendGapText(token.start)

        when (token.type) {
            TokenType.LINK -> {
                val (linkText, linkUrl) = token.groups
                val styleStart = builder.length
                builder.append(linkText)
                builder.addStyle(
                    body.copy(
                        color = MaterialTheme.colorScheme.primary,
                        textDecoration = TextDecoration.Underline
                    ),
                    styleStart,
                    builder.length
                )
                // Attach a string annotation with tag = "URL"
                builder.addStringAnnotation(
                    tag = "URL",
                    annotation = linkUrl,
                    start = styleStart,
                    end = builder.length
                )
            }

            TokenType.BOLD -> {
                val boldContent = token.groups[0]
                val styleStart = builder.length
                builder.append(boldContent)
                builder.addStyle(
                    body.copy(fontWeight = FontWeight.Bold),
                    styleStart,
                    builder.length
                )
            }

            TokenType.ITALIC -> {
                val italicContent = token.groups[0]
                val styleStart = builder.length
                builder.append(italicContent)
                builder.addStyle(
                    body.copy(fontStyle = FontStyle.Italic),
                    styleStart,
                    builder.length
                )
            }

            TokenType.HEADING -> {
                val headingLevel = token.groups[0].length // Number of '#' (1 to 3)
                val headingText = token.groups[1]
                val styleStart = builder.length
                builder.append(headingText)
                when (headingLevel) {
                    1 -> {
                        builder.addStyle(
                            MaterialTheme.typography.headlineMedium.toSpanStyle().copy(
                                color = MaterialTheme.colorScheme.primary
                            ),
                            styleStart,
                            builder.length
                        )
                    }

                    2 -> {
                        builder.addStyle(
                            MaterialTheme.typography.headlineSmall.toSpanStyle().copy(
                                color = MaterialTheme.colorScheme.secondary
                            ),
                            styleStart,
                            builder.length
                        )
                    }

                    3 -> {
                        builder.addStyle(
                            MaterialTheme.typography.titleLarge.toSpanStyle().copy(
                                color = MaterialTheme.colorScheme.tertiary
                            ),
                            styleStart,
                            builder.length
                        )
                    }

                    else -> {
                        // default style in case of an unexpected level
                        builder.addStyle(
                            MaterialTheme.typography.titleMedium.toSpanStyle(),
                            styleStart,
                            builder.length
                        )
                    }
                }
            }

            TokenType.LIST -> {
                builder.append("• ")
                builder.append(parseMarkdownToAnnotatedString(token.groups[0]))
                builder.appendLine()
            }
        }
        currentIndex = token.end
    }

    appendGapText(markdown.length)

    return builder.toAnnotatedString()
}

private data class MarkdownToken(
    val type: TokenType,
    val start: Int,
    val end: Int,
    val groups: List<String>
)


private enum class TokenType {
    LINK,
    BOLD,
    ITALIC,
    HEADING,
    LIST
}


@Preview
@Composable
private fun MarkdownTextPreview() {

    val markdownText = """
        # My Markdown Example
        
        This is a **bold** text and this is an *italic* text.
        
        ## List of Items
        - Item 1
        - Item 2
        - Item 3
        
        ## Link Example
        You can visit [example](https://example.com) for more information.
        
        """.trimIndent()


    NexcTheme(dynamicColor = false, themeMode = ThemeMode.DARK) {
        NexcScaffold {
            LazyColumn(
                contentPadding = it,
                modifier = Modifier.padding(10.dp)
            ) {
                item {
                    MarkdownText(text = markdownText)
                }
            }
        }
    }
}