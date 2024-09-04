package org.librefit.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.Done
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedCard
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import org.librefit.R
import org.librefit.data.Category
import org.librefit.data.Equipment
import org.librefit.data.Force
import org.librefit.data.Level
import org.librefit.data.Mechanic
import org.librefit.data.Muscle
import org.librefit.data.SharedViewModel
import org.librefit.util.exerciseEnumToStringId
import kotlin.enums.EnumEntries

@Composable
fun FiltersCard(
    isFilterExpanded: MutableState<Boolean>,
    viewModel: SharedViewModel
) {
    var iconRotation by remember { mutableFloatStateOf(0f) }

    OutlinedCard (
        modifier = Modifier
            .fillMaxWidth()
            .padding(15.dp),
    ){
        Row (
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .padding(15.dp)
        ){
            Row (verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)){
                Icon(
                    imageVector = ImageVector.vectorResource(id = R.drawable.ic_filter),
                    contentDescription = ""
                )
                Text(text = "Filters", style = MaterialTheme.typography.headlineSmall)
            }
            IconButton(
                onClick = {
                    isFilterExpanded.value = !isFilterExpanded.value
                    iconRotation = if (isFilterExpanded.value) 180f else 0f
                }
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowDropDown,
                    contentDescription = Icons.Default.ArrowDropDown.name,
                    modifier = Modifier.rotate(iconRotation)
                )
            }
        }


        val titles = listOf(
            R.string.label_force,
            R.string.label_level,
            R.string.label_mechanic,
            R.string.label_equipment,
            R.string.label_primary_muscles,
            R.string.label_secondary_muscles,
            R.string.label_category
        )

        val options = listOf(
            Force.entries,
            Level.entries,
            Mechanic.entries,
            Equipment.entries,
            Muscle.entries,
            Muscle.entries,
            Category.entries
        )


        //Animation to display the filters
        AnimatedVisibility(visible = isFilterExpanded.value) {
            Column (
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(15.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                //TODO this is temporary, until filter works
                ItemFilter(stringResource(titles[0]), options[0] , viewModel )
                ItemFilter(stringResource(titles[6]), options[6] , viewModel )

//                for (i in titles.indices){
//                    ItemFilter(title = stringResource(titles[i]), options = options[i], viewModel = viewModel)
//                    Spacer(modifier = Modifier.height(10.dp))
//                }
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ItemFilter(
    title: String,
    options: EnumEntries<out Enum<*>>,
    viewModel: SharedViewModel
) {

    Text(title)

    FlowRow(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        options.forEach { enum ->

            FilterChip(
                selected = viewModel.isEnumInList(enum),
                onClick = {
                    if (viewModel.isEnumInList(enum)){
                        viewModel.removeEnum(enum)
                    } else {
                        viewModel.addEnum(enum)
                    }
                },
                label = { Text(stringResource(exerciseEnumToStringId(enum)), maxLines = 1, overflow = TextOverflow.Ellipsis) },
                leadingIcon = if (viewModel.isEnumInList(enum)) {
                    {
                        Icon(
                            imageVector = Icons.Default.Done,
                            contentDescription = "",
                            modifier = Modifier.size(FilterChipDefaults.IconSize)
                        )
                    }
                } else {
                    null
                }
            )
        }
    }
}

@Preview
@Composable
fun FiltersCardPreview(){
    FiltersCard(remember { mutableStateOf(true) }, viewModel())
}